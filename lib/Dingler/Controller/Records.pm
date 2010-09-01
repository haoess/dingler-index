package Dingler::Controller::Records;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use Cache::FileCache;
use File::Basename qw(basename);
use List::Util qw(reduce sum);

=head1 NAME

Dingler::Controller::Records - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('journals');
    $c->forward('articles');
    $c->forward('tabulars');
    $c->forward('people');
    $c->forward('sloc');

    $c->stash(
        template => 'records.tt',
    );
}

=head2 journals

Journal statistics.

=cut

sub journals :Private {
    my ( $self, $c ) = @_;
    my $cache = Cache::FileCache->new({
        cache_root => $c->path_to( 'var', 'cache' )."",
        namespace  => 'dingler-records'
    });
    my $records = $cache->get('journals');
    if ( !$records ) {
        my $rs = $c->model('Dingler::Journal')->search(
            {
                'articles.id' => { like => 'ar%' },
            },
            {
                '+select' => [ { count => 'me.id', -as => 'a_count' } ],
                '+as'     => [ 'a_count' ],
                distinct  => 1,
                join      => 'articles',
                order_by  => 'a_count DESC',
            }
        );

        my $articles = sum map { $_->get_column('a_count') } $rs->all;
        my $least    = reduce { $a->get_column('a_count') < $b->get_column('a_count') ? $a : $b } $rs->all;

        my $tabs = $c->model('Dingler::Figure')->search(
            {
                reftype => 'tabular',
            },
            {
                select => 'ref',
                group_by => 'ref',
            }
        );
        my %journal_tabs;
        while ( my $tab = $tabs->next ) {
            my ($journal) = $tab->ref =~ /^tab(\d{3})/;
            $journal_tabs{ $journal }++;
        }
        my $most_tabs = reduce { $journal_tabs{$a} > $journal_tabs{$b} ? $a : $b } keys %journal_tabs;
        $records = {
            total           => $rs->count,
            articles        => $articles,
            most_articles   => $rs->first,
            least_articles  => $least,
            most_tabs       => $c->model('Dingler::Journal')->find({ id => "pj$most_tabs" }),
            most_tabs_count => $journal_tabs{$most_tabs},
        };
        $cache->set( 'journals', $records );
    }
    $c->stash(
        journal => $records,
    );
}

=head2 articles

Article statistics.

=cut

sub articles :Private {
    my ( $self, $c ) = @_;

    my $cache = Cache::FileCache->new({
        cache_root => $c->path_to( 'var', 'cache' )."",
        namespace  => 'dingler-records'
    });
    my $records = $cache->get('articles');
    if ( !$records ) {
        my $longest = $c->model('Dingler::Article')->search(
            {
                type => { -in => [ qw(art_patent art_undef) ] },
            },
            {
                '+select' => [ { '' => \'LENGTH(content) + LENGTH(front)', -as => 'a_length' } ],
                '+as'     => 'chars',
                order_by  => 'a_length DESC',
                rows      => 1,
            }
        );

        my $shortest = $c->model('Dingler::Article')->search(
            {
                type => { -in => [ qw(art_patent art_undef) ] },
            },
            {
                '+select' => [ { '' => \'LENGTH(content) + LENGTH(front)', -as => 'a_length' } ],
                '+as'     => 'chars',
                order_by  => 'a_length',
                rows      => 1,
            }
        );

        my $most_figures = $c->model('Dingler::Article')->search(
            {
                'figures.reftype' => 'figure',
            },
            {
                'select' => [ 'me.id', 'me.journal', 'me.title', { count => 'figures.ref', -as => 'f_count' } ],
                'as'     => [ 'id',    'journal',    'title',    'f_count' ],
                distinct  => 1,
                join      => 'figures',
                order_by  => 'f_count DESC',
                rows      => 1,
            }
        );
        $records = {
            longest      => {
                journal => {
                    id     => $longest->first->journal->id,
                    volume => $longest->first->journal->volume,
                    year   => $longest->first->journal->year,
                },
                id      => $longest->first->id,
                title   => $longest->first->title,
                chars   => $longest->first->get_column('chars'),
            },
            shortest     => {
                journal => {
                    id     => $shortest->first->journal->id,
                    volume => $shortest->first->journal->volume,
                    year   => $shortest->first->journal->year,
                },  
                id      => $shortest->first->id,
                title   => $shortest->first->title,
                chars   => $shortest->first->get_column('chars'),
            },
            most_figures => {
                journal => {
                    id     => $most_figures->first->journal->id,
                    volume => $most_figures->first->journal->volume,
                    year   => $most_figures->first->journal->year,
                },
                id      => $most_figures->first->id,
                title   => $most_figures->first->title,
                f_count => $most_figures->first->get_column('f_count'),
            },
        };
        $cache->set( 'articles', $records );
    }

    $c->stash(
        articles => $records,
    );
}

=head2 people

People statistics.

=cut

sub people :Private {
    my ( $self, $c ) = @_;

    my $cache = Cache::FileCache->new({
        cache_root => $c->path_to( 'var', 'cache' )."",
        namespace  => 'dingler-records'
    });
    my $records = $cache->get('people');
    if ( !$records ) {
        my $most_articles = $c->model('Dingler::Person')->search(
            {
                role => { -in => [ qw(author author_add author_orig) ] },
            },
            {
                'select' => [ 'me.id', { count => 'me.ref', -as => 'article_count' } ],
                'as'     => [ 'id', 'article_count' ],
                distinct  => 1,
                order_by  => 'article_count DESC',
                rows      => 1,
            }
        );
        my $most_articles_name = Dingler::Util::fullname( $c->config->{svn} . '/database/persons/persons.xml', $most_articles->first->id );
        $most_articles_name =~ s/(.*), (.*)/$2 $1/;

        my $most_patents = $c->model('Dingler::Person')->search(
            {
                role => 'patent_app',
            },
            {
                'select' => [ 'me.id', { count => 'me.ref', -as => 'article_count' } ],
                'as'     => [ 'id', 'article_count' ],
                distinct  => 1,
                order_by  => 'article_count DESC',
                rows      => 1,
            }
        );
        my $most_patents_name = Dingler::Util::fullname( $c->config->{svn} . '/database/persons/persons.xml', $most_patents->first->id );
        $most_patents_name =~ s/(.*), (.*)/$2 $1/;
        $records = {
            most_articles      => {
                id    => $most_articles->first->id,
                count => $most_articles->first->get_column('article_count'),
                name  => $most_articles_name,
            },
            most_patents       => {
                id    => $most_patents->first->id,
                count => $most_patents->first->get_column('article_count'),
                name  => $most_patents_name,
            },
        };
        $cache->set( 'people', $records );
    }
    $c->stash(
        people => $records,
    );
}

=head2 tabulars

Tabular statistics.

=cut

sub tabulars :Private {
    my ( $self, $c ) = @_;

    my $cache = Cache::FileCache->new({
        cache_root => $c->path_to( 'var', 'cache' )."",
        namespace  => 'dingler-records'
    });
    my $records = $cache->get('tabulars');
    if ( !$records ) {
        my %figures;
        my %sizes;

      IMAGE_MARKUP:
        foreach my $imt ( glob $c->config->{svn} . '/*/image_markup/*.xml' ) {
            my $xml; eval { $xml = XML::LibXML->new->parse_file( $imt ); 1 };
            next IMAGE_MARKUP if $@;
            my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
            $xpc->registerNs( 'tei', 'http://www.tei-c.org/ns/1.0' );

            $figures{ basename $imt, '.xml' } = $xpc->findnodes('//tei:zone')->size;
            $sizes{ basename $imt, '.xml' } = [ $xpc->findnodes('//tei:graphic/@width')."", $xpc->findnodes('//tei:graphic/@height')."" ];
        }

        my $most_tabs = reduce { $figures{$a} > $figures{$b} ? $a : $b } keys %figures;
        my ($most_figures_journal) = $most_tabs =~ /tab([0-9]{3})/;

        %sizes = map { s/px// for @{ $sizes{$_} }; $_ => $sizes{$_} } keys %sizes;
        my $biggest_tab = reduce { $sizes{$a}->[0]*$sizes{$a}->[1] > $sizes{$b}->[0]*$sizes{$b}->[1] ? $a : $b } keys %sizes;
        my ($biggest_tab_journal) = $biggest_tab =~ /tab([0-9]{3})/;
        $records = {
            most_figures         => $most_tabs,
            most_figures_count   => $figures{$most_tabs},
            most_figures_journal => "pj$most_figures_journal",
            biggest_tab          => $biggest_tab,
            biggest_tab_size     => [$sizes{$biggest_tab}->[0] * 4 * 0.0042335, $sizes{$biggest_tab}->[1] * 4 * 0.0042335],
            biggest_tab_journal  => "pj$biggest_tab_journal",
        };
        $cache->set( 'tabulars', $records );
    }
    $c->stash( tabulars => $records );
}

=head2 sloc

Source lines of code.

=cut

sub sloc :Private {
    my ( $self, $c ) = @_;
    my $cache = Cache::FileCache->new({
        cache_root => $c->path_to( 'var', 'cache' )."",
        namespace  => 'dingler-records'
    });
    my $records = $cache->get('sloc');
    if ( !$records ) {
        my $sloccount = '/usr/bin/sloccount';
        my $codedir   = $c->path_to( 'lib' );
        my $sloc      = `$sloccount $codedir | grep '^perl:'`;
        my $lines     = (split /\s+/, $sloc)[1];
        $records = {
            lines => $lines,
        };
        $cache->set( 'sloc', $records );
    }
    $c->stash( sloc => $records );
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
