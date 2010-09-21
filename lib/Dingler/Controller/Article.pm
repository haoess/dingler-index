package Dingler::Controller::Article;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Cache::FileCache;
use Dingler::Index;
use Dingler::Util;
use HTML::TagCloud;
use List::MoreUtils qw(uniq);
use Metadata::COinS;
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
    my $item  = $c->model('Dingler::Article')->find( $article );
    $c->detach('/default') if !$item;

    $c->stash(
        xml     => $xml,
        id      => $article,
        article => $article,
        journal => $journal,
        item    => $item,
        misc    => ($article =~ /^mi.*_/) ? 1 : 0,
    );

    my $favcookie = $c->req->cookie('dinglerfav');
    if ( $favcookie ) {
        $c->stash->{fav} = $c->model('Fav::Cookie')->search({
            article => $article,
            uniqid  => $favcookie->value,
        })->first;
    }

    $c->forward('set_meta', [$journal, $article]);
    $c->forward('article_xslt', [$journal, $article]);
    $c->forward('article_plain', [$journal, $article]);

    my $prev_article = $c->forward( 'step_article', [-1, $article] );
    my $next_article = $c->forward( 'step_article', [1, $article] );

    $c->stash->{bibtex} = $c->forward( 'bibtex', [$xml, $article] );

    my $coins = Metadata::COinS->new;
    $coins->set( 'atitle' => $item->title )
          ->set( 'title'  => 'Polytechnisches Journal' )
          ->set( 'jtitle' => 'Polytechnisches Journal' )
          ->set( 'date'   => $item->journal->year )
          ->set( 'volume' => $item->volume )
          ->set( 'spage'  => $item->pagestart )
          ->set( 'epage'  => $item->pageend )
          ->set( 'artnum' => $item->number || $item->parent->number )
          ->set( 'genre'  => 'article' );

    foreach my $author ( @{$c->stash->{authors}} ) {
        $coins->set( 'au' => $author );
    }
    $c->stash->{coins} = $coins;

    # page
    $c->stash(
        prev_article => $prev_article,
        next_article => $next_article,
        template     => 'article/view.tt',
    );
}

=head2 set_meta

=cut

sub set_meta :Private {
    my ( $self, $c, $journal, $article ) = @_;
    my $ar = $c->stash->{item};

    my $strip = \&Dingler::Util::strip;

    $c->stash(
        volume    => $strip->( $ar->volume ),
        title     => $strip->( $ar->title ),
        number    => $strip->( $ar->number || $ar->parent->number ),
        year      => $strip->( $ar->journal->year ),
        p_start   => $strip->( $ar->pagestart ),
        p_end     => $strip->( $ar->pageend ),
        facsimile => $strip->( $ar->facsimile ),
    );

    my @figures;
    foreach my $figure ( $ar->figures->search({ reftype => 'tabular' }) ) {
        push @figures, $figure->ref;
    }
    @figures = uniq @figures;
    $c->stash->{figures} = \@figures;

    my @authors;
    foreach my $author ( $ar->people ) {
        next unless $author->role eq 'author' or
                    $author->role eq 'originator' or
                    $author->role eq 'author_orig';
        push @authors, Dingler::Util::fullname( glob($c->config->{svn} . "/database/persons/persons.xml"), $author->id );
    }
    push @authors, 'Anonymus' if !@authors;
    $c->stash->{authors} = \@authors;
}

=head2 bibtex

=cut

sub bibtex :Private {
    my ( $self, $c, $xml, $article ) = @_;
    my $entry = Text::BibTeX::Entry->new;
    $entry->set_metatype( BTE_REGULAR );
    $entry->set_type( 'article' );
    $entry->set_key( "dingler:$article" );
    $entry->set( editor  => 'Dingler, Johann Gottfried' );
    $entry->set( journal => 'Polytechnisches Journal' );
    $entry->set( volume  => $c->stash->{volume} );
    if ( $c->stash->{misc} ) {
        if ( $c->stash->{number} ) {
            $entry->set( number  => sprintf '%s/Miszelle %s', $c->stash->{number}, $c->stash->{item}->position );
        }
    }
    else {
        $entry->set( number  => $c->stash->{number} );
    }
    $entry->set( title   => $c->stash->{title} );
    $entry->set( year    => $c->stash->{year} );
    $entry->set( pages   => $c->stash->{p_start} ne $c->stash->{p_end} ?
                            sprintf "%s--%s", $c->stash->{p_start}, $c->stash->{p_end} : $c->stash->{p_start} );

    $entry->set( author  => join ' and ', @{$c->stash->{authors}} );

    return $entry->print_s;
}

=head2 article_xslt

=cut

sub article_xslt :Private {
    my ($self, $c, $journal, $article) = @_;

    my $cache = Cache::FileCache->new({
        cache_root => $c->path_to( 'var', 'cache' )."",
        namespace  => 'dingler-articles'
    });
    my $xsl = $cache->get( $article );
    if ( not defined $xsl ) {
        if ( $c->stash->{misc} ) {
            $c->stash->{template} = 'misc.xsl';
        }
        else {
            $c->stash->{template} = 'unit.xsl';
        }
        $c->forward('Dingler::View::XSLT');
        $xsl = $c->res->body;
    }
    $cache->set( $article, $xsl );

    utf8::decode($xsl);
    $c->stash( xsl => $xsl );
    $c->res->body( undef );
}

=head2 article_plain

=cut

sub article_plain :Private {
    my ($self, $c, $journal, $article) = @_;

    my $cache = Cache::FileCache->new({
        cache_root => $c->path_to( 'var', 'cache' )."",
        namespace  => 'dingler-articles-plain'
    });
    my $plain = $cache->get( $article );
    if ( not defined $plain ) {
        if ( $c->stash->{misc} ) {
            $c->stash->{template} = 'misc-plain.xsl';
        }
        else {
            $c->stash->{template} = 'article-plain.xsl';
        }
        $c->forward('Dingler::View::XSLT');
        $plain = $c->res->body;
    }
    $cache->set( $article, $plain);

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
    my ($self, $c, $steps, $article) = @_;
    if ( $c->stash->{misc} ) {
        my $ar = $c->stash->{item};
        my $rs = $c->model('Dingler::Article')->search({
            position => $ar->position + $steps,
            journal  => $ar->get_column('journal'),
            parent   => $ar->get_column('parent'),
        })->first;
        return $rs ? $rs : $c->model('Dingler::Article')->search({
            parent   => undef,
            position => $ar->parent->position + $steps,
            journal  => $ar->get_column('journal'),
        })->first;
    }
    else {
        my $ar = $c->stash->{item};
        my $rs = $c->model('Dingler::Article')->search({
            position => $ar->position + $steps,
            journal  => $ar->get_column('journal'),
            parent   => undef,
        })->first;
        # check if rs is misc -> find first/last entry
        return unless $rs;
        my $misc = $c->model('Dingler::Article')->search(
            {
                parent => $rs->id,
            },
            {
                order_by => 'position ' . ($steps > 0 ? 'ASC' : 'DESC'),
                rows     => 1,
            },
        )->first;
        return $misc ? $misc : $rs;
    }
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
