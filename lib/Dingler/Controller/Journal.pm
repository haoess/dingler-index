package Dingler::Controller::Journal;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Dingler::Controller::Journal - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index :Path :Args(1) {
    my ( $self, $c, $journal ) = @_;
    
    # build the article list via XSLT
    $c->stash->{template} = 'article-list.xsl';
    my ($xml) = glob $c->config->{svn} . "/$journal/*Z.xml";
    $c->stash->{xml} = $xml;
    $c->stash->{journal} = $journal;
    $c->forward('Dingler::View::XSLT');
    $c->stash->{xsl} = $c->res->body;
    $c->res->body( undef );

    $c->stash(
        template => 'article/list.tt',
    )
}

=head1 AUTHOR

Frank Wiegand

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
