package Dingler::Controller::Records;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

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
    $c->stash(
        template => 'records.tt',
    );
}

=head2 journals

Journal statistics.

=cut

sub journals :Private {
    my ( $self, $c ) = @_;
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

    $c->stash(
        journal => {
            total           => $rs->count,
            articles        => $articles,
            most_articles   => $rs->first,
            least_articles  => $least,
            most_tabs       => $c->model('Dingler::Journal')->find({ id => "pj$most_tabs" }),
            most_tabs_count => $journal_tabs{$most_tabs},
        }
    );
}

=head2 articles

Article statistics.

=cut

sub articles :Private {
    my ( $self, $c ) = @_;

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

    $c->stash(
        articles => {
            longest      => $longest->first,
            shortest     => $shortest->first,
            most_figures => $most_figures->first,
        }
    );
}

sub person :Private {
    my ( $self, $c ) = @_;
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
