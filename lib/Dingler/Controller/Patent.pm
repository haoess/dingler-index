package Dingler::Controller::Patent;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Dingler::Controller::Patent - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

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

    my $rs = $c->model('Dingler::Patent')->search({ subtype => $subtype }, { order_by => 'date' });

    $c->stash(
        rs => $rs,
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
