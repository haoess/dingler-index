package Dingler::Controller::Timeline;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use utf8;
use File::Temp qw(tempfile);
use File::Basename qw(basename);

=head1 NAME

Dingler::Controller::Timeline - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(
        template => 'timeline/dingler.tt',
    );
}

=head2 dta

=cut

sub dta :Local {
    my ( $self, $c, $year ) = @_;
    $c->stash(
        template => 'timeline/dta.tt',
        year     => $year,
    );
}

=head2 patent

=cut

sub patent :Local {
    my ( $self, $c, $year ) = @_;
    $c->stash(
        template => 'timeline/patent.tt',
        year     => $year,
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
