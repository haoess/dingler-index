package Dingler::Controller::Search;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use utf8;
use Data::Page;

my @langmap = (
    [ qw(english England) ],
    [ qw(french Frankreich) ],
    [ qw(austrian Österreich) ],
    [ qw(prussian Preußen) ],
    [ qw(scottish Schottland) ],
    [ qw(american USA) ],
);

my @texttypes = (
    [ art     => 'Artikel',            'art_undef' ],
    [ misc    => 'Miszelle',           'misc_undef' ],
    [ lit     => 'Literatur',          'art_literature' ],
    [ pat     => 'Patentbeschreibung', 'art_patent' ],
    [ patlist => 'Patentverzeichnis',  'art_patents', 'misc_patents' ],
    [ idx     => 'Index',              'XXX' ],
    [ add     => 'Hg.-Ergänzung',      'XXX' ],
    [ other   => 'Sonstiges',          'XXX', 'YYY' ], # Vorworte, Widmungen, Anzeigen etc.
);

my %tt_reverse;
foreach my $tt (@texttypes) {
    foreach my $typedef ( @$tt[ 2 .. $#$tt ] ) {
        $tt_reverse{ $typedef } = $tt->[0];
    }
}

=head1 NAME

Dingler::Controller::Search - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 auto

=cut

sub auto :Private {
    my ( $self, $c ) = @_;
    $c->stash(
        langmap   => \@langmap,
        texttypes => \@texttypes,
    );
    return 1;
}

=head2 help

=cut

sub help :Local {
    my ( $self, $c ) = @_;
    $c->stash(
        template => 'search/help.tt',
    );
}

=head2 extended

=cut

sub extended :Local {
    my ( $self, $c ) = @_;
    $c->stash(
        template => 'search/extended.tt',
    );
}

=head2 search

=cut

sub search :Global {
    my ( $self, $c ) = @_;

    my $dbh = $c->model('Dingler::Article')->result_source->schema->storage->dbh;

    my $add_to_where = '';

    ###################################
    # search terms
    my $search = $c->req->params->{q};

    # XXX move out to Dingler::Util
    for ($search) {
        s/\A\s+//;
        s/\s+\z//;
        s/\s+/ /g;
    }
    my $q = $dbh->quote($search);

    # test query if it fits to to_tsquery
    my $query_func = 'to_tsquery';
    eval { $dbh->do( "SELECT to_tsquery($q)" ); 1 };
    $query_func = 'plainto_tsquery' if $@;

    ###################################
    # content fields (text, titles etc.) to search in XXX
    my $in = $c->req->params->{in} || '';
    my $search_index = $in eq 'title' ? 'titletsv' :
                                        'tsv';

    ###################################
    # text types to search in
    my @ts = grep { defined } ref $c->req->params->{ts} ? @{$c->req->params->{ts}} : $c->req->params->{ts};
    my @add;
    foreach my $texttype ( @ts ) {
        push @add, map { 'me.type = ' . $dbh->quote($_) }
                   map { @$_[2 .. $#$_] }
                   grep { $_->[0] eq $texttype } @texttypes;
    }
    $add_to_where .= ' AND (' . (join " OR $_ ", @add) . ')' if @add;

    ###################################
    # period of time
    my $from = $c->req->params->{from};
    my $to   = $c->req->params->{to};
    if ( $from && $from =~ /\A1[89][0-9][0-9]\z/ ) {
        $add_to_where .= ' AND journal.year >= ' . $dbh->quote($from);
    }
    if ( $to && $to =~ /\A1[89][0-9][0-9]\z/ ) {
        $add_to_where .= ' AND journal.year <= ' . $dbh->quote($to);
    }

    ###################################
    # ordering hits
    my $sort = $c->req->params->{sort} || 'rank';
    my $order_by = $sort eq 'author' ? '' : # XXX
                   $sort eq 'title'  ? 'title' :
                   $sort eq 'date'   ? 'journal.year, me.number' : 'rank DESC';

    # all hits
    my $hits = $c->model('Dingler::Article')->search(
        { },
        {
            select => [ 'me.id', 'me.type', 'journal.year' ],
            as     => [ 'id', 'type', 'year' ],
            from   => \qq[ article me, $query_func('german', $q) query, journal journal ],
            where  => \qq[ query @@ $search_index AND me.journal = journal.id AND me.type != 'art_miscellanea' $add_to_where ],
        }
    );
    my $count = $hits->count;

    # set up pager
    my $limit = 200;
    my $page = $c->req->params->{p} || 1;
    $page = 1 if $page !~ /\A[0-9]+\z/;
    my $pager = Data::Page->new;
    $pager->total_entries( $count );
    $pager->entries_per_page( $limit );
    $pager->current_page( $page );

    # DBIC at its best
    my $matches = $c->model('Dingler::Article')->search(
        {},
        {
            select => [
                qw(id journal title number pagestart type rank),
                \q[ ts_headline(content, query, 'MaxFragments=2') ],
                qw(journal year volume parent position),
            ],
            as => [
                qw(id journal title number pagestart type),
                qw(rank headline),
                qw(journal year volume parent position),
            ],
            from => [
                {
                    xx => $c->model('Dingler::Article')->search(
                        {},
                        {
                            select   => \qq[
                                me.id, me.journal, me.title, me.number, me.pagestart, me.type, me.content, me.parent, me.position,
                                journal.year, journal.volume,
                                ts_rank_cd($search_index, query) rank, query
                            ],
                            from     => \qq[ article me, journal, $query_func('german', $q) query ],
                            where    => \qq[ query @@ $search_index AND me.journal = journal.id AND me.type != 'art_miscellanea' $add_to_where ],
                            order_by => $order_by,
                            rows     => $limit,
                            offset   => ($page - 1) * $limit,
                        }
                    )->as_query,
                },
            ],
        },
    );

    $c->forward('facets', [$hits]);

    $c->stash(
        template => 'search/result.tt',
        q        => $search,
        pager    => $pager,
        matches  => $matches,
    );
}

=head2 facets

=cut

sub facets :Private {
    my ($self, $c, $matches) = @_;
    while ( my $match = $matches->next ) {
        my $year = $match->get_column('year');
        $year =~ /\A([0-9]{3})/;
        $c->stash->{facet}{decade}{ $1 }++;

        $c->stash->{facet}{texttype}{ $tt_reverse{$match->type} }++;
        #my $figures = $match->figures->search( undef, { group_by => 'url' } )->count;
        #$c->stash->{figures} += $figures;
    }
    use Data::Dumper; warn Dumper $c->stash->{facet};
    $matches->reset; # don't forget
    return;
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
