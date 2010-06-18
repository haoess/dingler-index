package Dingler::Controller::Ticket;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use DateTime;

=head1 NAME

Dingler::Controller::Ticket - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(
        template => 'ticket/list.tt',
        tickets  => [ $c->model('Ticket::Ticket')->all ],
    );
}

=head2 report

=cut

sub report :Local {
    my ( $self, $c, $article ) = @_;
    my $bugtype = $c->req->params->{bugtype};
    my $ocrword = $c->req->params->{ocrword};
    my $email   = $c->req->params->{email};
    my $note    = $c->req->params->{note};

    my $ticket = $c->model('Ticket::Ticket')->create({
        bugtype => $bugtype,
        article => $article,
        ocrword => $ocrword,
        email   => $email,
        note    => $note,
        created => DateTime->now,
        changed => DateTime->now,
        status  => 'open',
        comment => undef,
    });

    $c->res->content_type('text/plain');
    $c->res->body("Ticket #" . $ticket->id ." angelegt.");
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
