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

    my $rs = $c->model('Dingler::Person')->search(
        {
            'me.id'      => $person,
            'ref.id' => { '!=' => $article },
        },
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

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 AUTHOR

Frank Wiegand

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
