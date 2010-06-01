package Dingler::Controller::Journal;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dingler::Controller::Journal - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index :Path :Args(1) {
    my ( $self, $c, $journal ) = @_;

    $c->forward('article_list', [$journal]);

    $c->stash(
        template => 'article/list.tt',
    );
}

=head2 article_list

=cut

sub article_list :Private {
    my ($self, $c, $journal) = @_;

    $c->stash->{template} = 'article-list.xsl';
    my ($xml) = glob $c->config->{svn} . "/$journal/*Z.xml";
    $c->stash->{xml} = $xml;
    $c->stash->{journal} = $journal;
    $c->forward('Dingler::View::XSLT');

    my $xsl = $c->res->body;
    utf8::decode $xsl;
    $c->stash( xsl => $xsl );
    $c->res->body( undef );
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
