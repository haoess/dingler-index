package Dingler::Controller::Patent;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

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
    return 1;
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
}

=head2 c

Browse patents by country.

=cut

sub c :Local {
    my ( $self, $c, $subtype ) = @_;

    my $limit = 20;
    my $page = $c->req->params->{p} || 1;
    $page = 1 if $page !~ /\A[0-9]+\z/;
    my $pager = Data::Page->new;
    $pager->total_entries( $c->model('Dingler::Patent')->search({ subtype => $subtype })->count );
    $pager->entries_per_page( $limit );
    $pager->current_page( $page );

    my $rs = $c->model('Dingler::Patent')->search(
        {
            subtype => $subtype,
        },
        {
            order_by => 'date',
            rows     => $limit,
            offset   => ($page - 1) * $limit,
        }
    );

    $c->stash(
        pager   => $pager,
        rs      => $rs,
        subtype => (grep { $_->[0] eq $subtype } @langmap)[0],
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
