package Dingler::Controller::Page;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Dingler::Controller::Page - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 page

=cut

sub index :Path :Args(2) {
    my ( $self, $c, $journal, $page ) = @_;
    my $rs = Dingler->model('Dingler::Article')->search(
        {
            journal => $journal,
            $page   => { -between => [ \'pagestart::int', \'pageend::int' ] },
        },
    );
    if ( $rs->count ) {
        $c->res->redirect( $c->uri_for("/article", $journal, $rs->first->id ) ); #, "#$journal" . "pb_$page"
        $c->detach;
    }
    $c->detach('/default');
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
