package Dingler::Controller::Article;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use Dingler::Index;
use HTML::TagCloud;

=head1 NAME

Dingler::Controller::Article - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(2) {
    my ( $self, $c, $journal, $article ) = @_;
    
    # build the article via XSLT
    $c->stash->{template} = 'article.xsl';
    my ($xml) = glob $c->config->{svn} . "/$journal/*Z.xml";
    $c->stash->{xml} = $xml;
    $c->stash(
        article => $article,
        journal => $journal,
    );
    $c->forward('Dingler::View::XSLT');
    $c->stash->{xsl} = $c->res->body;
    $c->res->body( undef );

    # plain article
    $c->stash->{template} = 'article-plain.xsl';
    $c->forward('Dingler::View::XSLT');
    my $plain = $c->res->body;
    my $index = Dingler::Index->new({ text => $plain });
    my %words = %{ $index->words };
    my $cloud = HTML::TagCloud->new( levels => 30 );
    while ( my ($key, $value) = each %words ) {
        $cloud->add( $key, undef, $value );
    }
    $c->stash( cloud => $cloud );
    $c->res->body( undef );

    # page
    $c->stash(
        template => 'article/view.tt',
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
