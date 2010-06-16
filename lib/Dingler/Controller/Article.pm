package Dingler::Controller::Article;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Dingler::Index;
use HTML::TagCloud;
use Text::BibTeX qw(:metatypes);

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

    my $prev_article = $c->forward( 'step_article', ['preceding', $article] );
    my $next_article = $c->forward( 'step_article', ['following', $article] );

    $c->stash->{bibtex} = $c->forward( 'bibtex', [$xml, $article] );

    # page
    $c->stash(
        prev_article => $prev_article,
        next_article => $next_article,
        template     => 'article/view.tt',
    );
}

sub bibtex :Private {
    my ( $self, $c, $xml, $article ) = @_;
    my $entry = Text::BibTeX::Entry->new;
    $entry->set_metatype( BTE_REGULAR );
    $entry->set_type( 'article' );
    $entry->set_key( "dingler:$article" );

    # editor
    $entry->set( editor => 'Dingler, Johann Gottfried' );

    my $doc = XML::LibXML->new
                         ->parse_file( $c->path_to('var', 'volumes.xml')->stringify )
                  or die $!;
    my $xpc = XML::LibXML::XPathContext->new( $doc ) or die $!;

    # journal
    $entry->set( journal => 'Polytechnisches Journal' );

    # volume
    my $volume = $xpc->find( "//journal[file='" . $c->stash->{journal} . "']/volume[1]" );
    $entry->set( volume => "$volume" );

    # title
    my $title = $xpc->find( "//article[id='$article']/title[1]" );
    $entry->set( title => "$title" );

    # year
    my $year = $xpc->find( "//journal[file='" . $c->stash->{journal} . "']/year[1]" );
    $entry->set( year => "$year" );

    # pages
    my $p_start = $xpc->find( "//article[id='$article']/pagestart[1]" );
    my $p_end   = $xpc->find( "//article[id='$article']/pageend[1]" );
    $entry->set( pages => "$p_start" ne "$p_end" ? "$p_start--$p_end" : "$p_start" );

    return $entry->print_s;
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
    my ($self, $c, $way, $article) = @_;

    my $doc = XML::LibXML->new
                         ->parse_file( $c->path_to('var', 'volumes.xml')->stringify )
                  or die $!;
    my $xpc = XML::LibXML::XPathContext->new( $doc ) or die $!;
    my $ret = $xpc->find( "//article[id='$article']/$way-sibling::article[1]/id" );
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
