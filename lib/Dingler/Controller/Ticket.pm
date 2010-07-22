package Dingler::Controller::Ticket;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use DateTime;
use XML::Feed;

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

=head2 rss

=cut

sub rss :Local {
    my ( $self, $c ) = @_;
    my $tickets = $c->model('Ticket::Ticket')->search( undef, { order_by => 'created DESC' } );
    my $feed = XML::Feed->new('Atom');
    $feed->title( 'Dingler-Online Ticket Feed' );
    $feed->link( $c->req->base );
    while( my $entry = $tickets->next ) {
        my $feed_entry = XML::Feed::Entry->new('Atom');
        $feed_entry->title( sprintf '[%s] %s', $entry->bugtype, $entry->article );
        $feed_entry->link( $c->uri_for('/ticket/view', $entry->id) );
        $feed_entry->issued( $entry->created );
        $feed->add_entry( $feed_entry );
    }
    $c->res->content_type( 'application/atom+xml' );
    $c->res->body( $feed->as_xml );
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
