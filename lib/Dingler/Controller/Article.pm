package Dingler::Controller::Article;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Dingler::Index;
use HTML::TagCloud;

=head1 NAME

Dingler::Controller::Article - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index :Path :Args(2) {
    my ( $self, $c, $journal, $article ) = @_;
    my ($xml) = glob $c->config->{svn} . "/$journal/*Z.xml";
    $c->stash->{xml} = $xml;

    $c->forward('article_xslt', [$journal, $article]);
    $c->forward('article_plain', [$journal, $article]);

    my $prev_article = $c->forward( 'step_article', ['preceding', $xml, $article] );
    my $next_article = $c->forward( 'step_article', ['following', $xml, $article] );

    # page
    $c->stash(
        prev_article => $prev_article,
        next_article => $next_article,
        template     => 'article/view.tt',
    );
}

=head2 article_xslt

=cut

sub article_xslt :Private {
    my ($self, $c, $journal, $article) = @_;

    $c->stash->{template} = 'article.xsl';
    $c->stash(
        article => $article,
        journal => $journal,
    );
    $c->forward('Dingler::View::XSLT');

    my $xsl = $c->res->body;
    utf8::decode($xsl);
    $c->stash( xsl => $xsl );
    $c->res->body( undef );
}

=head2 article_plain

=cut

sub article_plain :Private {
    my ($self, $c, $journal, $article) = @_;

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
}

=head2 step_article

=cut

sub step_article :Private {
    my ($self, $c, $way, $xml, $article) = @_;

    my $ns_uri = 'http://www.tei-c.org/ns/1.0';
    my $parser = XML::LibXML->new();
    my $doc = $parser->parse_file($xml) or die $!;
    my $xpc = XML::LibXML::XPathContext->new( $doc ) or die $!;
    $xpc->registerNs( 'tei', $ns_uri );

    my $ret = $xpc->find( '//tei:text[@xml:id="' . $article . '"]/' . $way . '-sibling::tei:text[@type="art_undef" or @type="art_patent"][1]/@xml:id' );
    return $ret;
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
