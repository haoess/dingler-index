package Dingler::Controller::Ticket;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Dingler::Controller::Ticket - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 report

=cut

sub report :Local {
    my ( $self, $c, $article ) = @_;
    my $bugtype = $c->req->params->{bugtype};
    my $ocrword = $c->req->params->{ocrword};
    my $email   = $c->req->params->{email};
    my $note    = $c->req->params->{note};
    $c->res->content_type('text/plain');
    $c->res->body('Feedback erhalten.');
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
