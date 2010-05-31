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

    # build the plain article for the tag cloud
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

    my $prev_article = $c->forward( 'step_article', ['preceding', $xml, $article] );
    my $next_article = $c->forward( 'step_article', ['following', $xml, $article] );

    # page
    $c->stash(
        prev_article => $prev_article,
        next_article => $next_article,
        template     => 'article/view.tt',
    )
}

sub step_article :Private {
    my ($self, $c, $way, $xml, $article) = @_;

    my $ns_uri = 'http://www.tei-c.org/ns/1.0';
    my $parser = XML::LibXML->new();
    $parser->line_numbers(1);
    $parser->load_ext_dtd(0);
    $parser->expand_entities(0);

    my $doc = $parser->parse_file($xml) or die $!;
    my $xpc = XML::LibXML::XPathContext->new( $doc ) or die $!;
    $xpc->registerNs( 'tei', $ns_uri );

    my $ret = $xpc->find( '//tei:text[@xml:id="' . $article . '"]/' . $way . '::tei:text[@type="art_undef" or @type="art_patent"][1]/@xml:id' );
    return $ret;
}

sub next_article {}

=head1 AUTHOR

Frank Wiegand

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
