package Dingler::Controller::Patent;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use Scalar::Util qw(weaken);

use utf8;
my @langmap = (
    [ qw(english England) ],
    [ qw(french Frankreich) ],
    [ qw(austrian Österreich) ],
    [ qw(prussian Preußen) ],
    [ qw(scottish Schottland) ],
    [ qw(american USA) ],
);

=head1 NAME

Dingler::Controller::Patent - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 auto

=cut

sub auto :Private {
    my ( $self, $c ) = @_;
    $c->stash( langmap => \@langmap );
    $c->stash(
        render_patent => sub {
            my ( $id, $xml ) = @_;

            my $cache = Cache::FileCache->new({
                cache_root => $c->path_to( 'var', 'cache' )."",
                namespace  => 'dingler-patents'
            });
            my $xsl = $cache->get( $id );
            if ( not defined $xsl ) {
                $c->stash(
                    id       => $id,
                    template => 'unit.xsl',
                    xml      => $xml,
                );
                $c->forward('Dingler::View::XSLT');
                $xsl = $c->res->body;
                utf8::decode($xsl);
                $c->res->body( undef );
            }
            $cache->set( $id, $xsl );
            return $xsl;
        },
    );
    return 1;
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $search = {};

    if ( my $subtype = $c->req->params->{subtype} ) {
        $search->{subtype} = $subtype;
    }

    if ( my $decade = $c->req->params->{decade} ) {
        $search->{date} = { -between => [ "$decade-01-01", ($decade+9)."-12-31" ] };
    }

    if ( keys %$search ) {
        $c->forward('build_rs', [$search]);
        $c->stash( template => 'patent/list.tt' );
    }
    else {
        $c->stash( template => 'patent/index.tt' );
    }
}

=head2 build_rs

=cut

sub build_rs :Private {
    my ( $self, $c, $search ) = @_;
    my $limit = 20;
    my $page = $c->req->params->{p} || 1;
    $page = 1 if $page !~ /\A[0-9]+\z/;
    my $pager = Data::Page->new;
    $pager->total_entries( $c->model('Dingler::Patent')->search( $search )->count );
    $pager->entries_per_page( $limit );
    $pager->current_page( $page );

    my $rs = $c->model('Dingler::Patent')->search( $search );

    while ( my $match = $rs->next ) {
        my $subtype = $match->subtype;
        $c->stash->{facet}{subtype}{$subtype}++;

        my $date = $match->get_column('date');
        if ( $date ) {
            $date =~ /\A(\d{3})/;
            $c->stash->{facet}{decade}{$1}++;
        }
    }
    $rs->reset; # don't forget

    $rs = $rs->search(
        $search,
        {
            order_by => 'date',
            rows     => $limit,
            offset   => ($page - 1) * $limit,
        }
    );
    $c->stash(
        pager => $pager,
        rs    => $rs,
    );
}

=head2 XXX

=cut

sub sineapp :Local {
    my ( $self, $c, $subtype ) = @_;

    my $rs = $c->model('Dingler::Patent')->search(
        {
            'patent_apps.id' => undef,
        },
        {
            order_by => 'date',
            join => [ 'patent_apps' ],
            rows => 20,
        }
    );

    $c->stash(
        rs      => $rs,
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
