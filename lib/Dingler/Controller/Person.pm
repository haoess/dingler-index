package Dingler::Controller::Person;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Dingler::Index;
use File::Temp qw(tempfile);
use XML::LibXML;

=head1 NAME

Dingler::Controller::Person - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index :Path :Args(2) {
    my ( $self, $c, $person, $article ) = @_;
    my $xml = $c->config->{svn} . '/database/persons/persons.xml';
    $c->stash->{xml} = $xml;
    $c->stash->{template} = 'person.xsl';

    my $search_args = {
        'me.id' => $person,
    };
    if ( $article ) {
        $search_args->{ 'ref.id' } = { '!=' => $article };
    }
    my $rs = $c->model('Dingler::Person')->search(
        $search_args,
        {
            join => [ 'ref' ],
        },
    );
    my @texts;
    my $p_xml = "<refs>\n";
    while ( my $p = $rs->next ) {
        $p_xml .= sprintf "  <ref>%s</ref>\n", $p->ref->id;
        push @texts, $p->ref->front, $p->ref->content;
    }
    $p_xml .= "</refs>";
    my ($tempfh, $tempname) = tempfile;
    print $tempfh $p_xml;
    close $tempfh;

    $c->stash(
        article => $article,
        person  => $person,
        ptrs    => $tempname,
    );
    $c->forward('Dingler::View::XSLT');
    unlink $tempname;
    my $xsl = $c->res->body;
    utf8::decode($xsl);
    $c->stash( xsl => $xsl );
    $c->res->body( undef );

    my $index = Dingler::Index->new({ text => join( ' ', @texts ) });
    my %words = %{ $index->words };
    my $cloud = HTML::TagCloud->new( levels => 30 );
    while ( my ($key, $value) = each %words ) {
        $cloud->add( $key, undef, $value );
    }

    $c->stash(
        cloud    => $cloud,
        template => 'person/view.tt',
    );
}

=head2 list

=cut

sub list :Local {
    my ( $self, $c, $letter ) = @_;
    my $xml = $c->config->{svn} . '/database/persons/persons.xml';
    $letter ||= 'A';
    $c->stash(
        letter => $letter,
        xml    => $xml,
    );
    $c->stash->{template} = 'person-list.xsl';
    $c->forward('Dingler::View::XSLT');
    my $xsl = $c->res->body;
    utf8::decode($xsl);
    $c->stash( xsl => $xsl );
    $c->res->body( undef );

    $c->stash(
        author     => $c->model('Dingler::Person')->search_rs({ role => { '=' => ['author', 'author_orig'] } }),
        patent_app => $c->model('Dingler::Person')->search_rs({ role => 'patent_app' }),
        other      => $c->model('Dingler::Person')->search_rs({ role => { -not_in => ['author',  'author_orig', 'patent_app'] } }),
    );

    $c->stash(
        template => 'person/list.tt',
    );
}

=head2 beacon

=cut

sub beacon :Global {
    my ( $self, $c ) = @_;
    my $xml = XML::LibXML->new->parse_file( $c->config->{svn} . '/database/persons/persons.xml' );
    my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
    $xpc->registerNs( 'tei', 'http://www.tei-c.org/ns/1.0' );

    my %pnds;
    foreach my $person ( $xpc->findnodes('//tei:person') ) {
        my $pnd = $xpc->find( 'tei:note[@type="pnd"]', $person );
        next unless $pnd;
        my $id = $xpc->find( '@xml:id', $person );
        my $count = $c->model('Dingler::Person')->search({ id => $id })->count;
        next unless $count;
        $pnds{$pnd} = $count;
    }
    $c->res->content_type( 'text/plain' );
    my $out = <<"EOT";
#FORMAT: PND-BEACON
#TARGET: @{[ $c->uri_for('/person/pnd') ]}/{ID}
#VERSION: 0.1
#FEED: @{[ $c->req->uri ]}
#CONTACT: Frank Wiegand <frank.wiegand\@gmail.com>
#INSTITUTION: Digitalisierung des Polytechnischen Journals (Institut fuer Kulturwissenschaft, Humboldt-Universitaet zu Berlin)
EOT
    $out .= join "\n", map { sprintf "%s|%d", $_, $pnds{$_} } sort keys %pnds;
    $c->res->body( $out );
}

=head2 pnd

=cut

sub pnd :Local {
    my ( $self, $c, $pnd ) = @_;
    my $xml = XML::LibXML->new->parse_file( $c->config->{svn} . '/database/persons/persons.xml' );
    my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
    $xpc->registerNs( 'tei', 'http://www.tei-c.org/ns/1.0' );
    my ( $entry ) = $xpc->findnodes("//tei:person[tei:note[\@type='pnd'] = '$pnd']");
    if ( $entry ) {
        my $id = $xpc->find( '@xml:id', $entry );
        my $person = $c->model('Dingler::Person')->search({ person => $id });
        $c->forward('index', [ $id, '' ]);
    }
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 AUTHOR

Frank Wiegand

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
