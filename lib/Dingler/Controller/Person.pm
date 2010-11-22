package Dingler::Controller::Person;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Dingler::Index;
use File::Temp qw(tempfile);
use JSON;

=head1 NAME

Dingler::Controller::Person - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index :Path :Args(2) {
    my ( $self, $c, $persid, $skipid ) = @_;

    my $person = $c->model('Dingler::Person')->find({ id => $persid });
    $c->detach('/default') unless $person;
    $c->stash->{person} = $person;

    # the person's articles
    if ( $skipid ) {
        my $article = $c->model('Dingler::Article')->find({ id => $skipid });
        $c->stash->{personarticles} = Dingler::Util::personarticles( $persid, $article->uid );
    }
    else {
        $c->stash->{personarticles} = Dingler::Util::personarticles( $persid );
    }

    # the person's tag cloud
    my $rs = $c->model('Dingler::Personref')->search(
        { 'me.id' => $persid },
        { join => [ 'ref' ] },
    );
    my @texts;
    while ( my $p = $rs->next ) {
        push @texts, $p->ref->front, $p->ref->content;
    }
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
    $letter ||= 'A';

    my $filter = $c->req->params->{filter};
    my %search = $filter eq 'author'     ? ( 'personrefs.role' => { '=' => ['author', 'author_orig'] } )
               : $filter eq 'patent_app' ? ( 'personrefs.role' => 'patent_app')
               : $filter eq 'other'      ? ( 'personrefs.role' => { -not_in => ['author',  'author_orig', 'patent_app'] } )
               :                           ();

    my $names = $c->model('Dingler::Person')->search(
        {
            surname => { like => "$letter%" },
            %search,
        },
        {
            order_by => 'surname, forename',
            join     => [ 'personrefs' ],
            prefetch => [ 'personrefs' ],
        }
    );

    $c->stash(
        names      => $names,
        personarticles => \&Dingler::Util::personarticles,
        author     => $c->model('Dingler::Personref')->search_rs({ role => { '=' => ['author', 'author_orig'] } }),
        patent_app => $c->model('Dingler::Personref')->search_rs({ role => 'patent_app' }),
        other      => $c->model('Dingler::Personref')->search_rs({ role => { -not_in => ['author',  'author_orig', 'patent_app'] } }),
        letter     => $letter,
        template   => 'person/list.tt',
    );
}

=head2 beacon

=cut

sub beacon :Global {
    my ( $self, $c ) = @_;
    my %pnds;
    my $rs = $c->model('Dingler::Person')->search(
        { -and => [ 'me.pnd' => { '!=' => undef }, 'me.pnd' => { '!=' => '' } ] },
    );
    while ( my $row = $rs->next ) {
        $pnds{ $row->pnd } = $row->personrefs->count if $row->personrefs->count;
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
    my $person = $c->model('Dingler::Person')->find({ pnd => $pnd });
    $c->detach('/default') unless $person;
    $c->forward('index', [ $person->id, '' ]);
}

=head2 search

=cut

sub search :Local {
    my ( $self, $c ) = @_;
    my $q = $c->req->params->{q} || '';

    my %cond = _prepare_cond( $q );
    my %attrs = (
        order_by => 'surname, forename',
    );
    my $names = $c->model('Dingler::Person')->search( \%cond, \%attrs );

    $c->stash(
        names    => $names,
        personarticles => \&Dingler::Util::personarticles,
        template => 'person/list.tt',
    );
}

=head2 search_ac

=cut

sub search_ac :Local {
    my ( $self, $c ) = @_;
    my $q = $c->req->params->{q} || '';

    if ( length $q <= 2 ) {
        $c->res->content_type( 'application/json; charset=utf-8' );
        $c->res->body( '' );
    }

    my %cond = _prepare_cond( $q );
    my %attrs = (
        order_by => 'surname, forename',
    );
    my $names = $c->model('Dingler::Person')->search( \%cond, \%attrs );

    my @result;
    while ( my $person = $names->next ) {
        my $name = sprintf '%s, %s %s %s', $person->surname, $person->addname, $person->forename, $person->namelink;
        $name =~ s/\s+/ /g;
        $name =~ s/,\s+$//g;
        push @result, $name;
    }
    my $out = join "\n", @result;
    $c->res->content_type( 'text/plain; charset=utf-8' );
    $c->res->body( $out || ' ' );
}

sub _prepare_cond {
    my $q = shift;

    # normalize spaces
    for ( $q ) {
        s/^\s+//;
        s/\s+$//;
        s/\s+/ /g;
    }

    my %cond;

    if ( $q =~ /^1[0-9]{7}[0-9X]$/ ) { # PND
        $cond{pnd} = $q;
    }
    #elsif ( ) { # VIAF
    #
    #}
    elsif ( $q =~ /,/ ) {
        my ( $surname, $forename ) = split /\s*,\s*/, $q, 2;
        $cond{surname}  = { ilike => $surname };
        $cond{forename} = { ilike => substr( $forename, 0, 5 ) . '%' };
    }
    elsif ( $q =~ /\s/ ) {
        my @parts = split /\s+/, $q;
        my $surname = pop @parts;
        my $forename = join ' ', @parts;
        $cond{surname}  = { ilike => "$surname%" };
        $cond{forename} = { ilike => substr( $forename, 0, 5 ) . '%' };
    }
    else {
        $cond{surname} = { ilike => "$q%" };
    }

    return %cond;
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
