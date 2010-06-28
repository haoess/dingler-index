package Dingler::Controller::Search;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use Data::Page;

=head1 NAME

Dingler::Controller::Search - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 help

=cut

sub help :Local {
    my ( $self, $c ) = @_;
    $c->stash(
        template => 'search/help.tt',
    );
}

=head2 search

=cut

sub search :Global {
    my ( $self, $c ) = @_;
    my $search = $c->req->params->{q};
    for ($search) {
        s/\A\s+//;
        s/\s+\z//;
        s/\s+/ /g;
    }

    my $dbh = $c->model('Dingler::Article')->result_source->schema->storage->dbh;
    my $q = $dbh->quote($search);

    # test query if it fits to to_tsquery
    my $query_func = 'to_tsquery';
    eval { $dbh->do( "SELECT to_tsquery($q)" ); 1 };
    $query_func = 'plainto_tsquery' if $@;

    # facet search
    my $add = '';
    my @facets = ();
    my $decade = $c->req->params->{decade};
    if ( defined $decade && $decade =~ /\A(1[89][0-9])0\z/ ) {
        $add .= " AND journal.year LIKE " . $dbh->quote("$1%");
        push @facets, [ decade => $decade ];
    }

    my $texttype = $c->req->params->{texttype};
    if ( defined $texttype && $texttype =~ /\A(art_(?:patent|undef))\z/ ) {
        $add .= " AND me.type = " . $dbh->quote($1);
        push @facets, [ texttype => $texttype ];
    }

    # all hits
    my $hits = $c->model('Dingler::Article')->search(
        { },
        {
            select => [ 'me.id', 'me.type', 'journal.year' ],
            as     => [ 'id', 'type', 'year' ],
            from   => \qq[ article me, $query_func('german', $q) query, journal journal ],
            where  => \qq[ query @@ tsv AND me.journal = journal.id $add ],
        }
    );
    my $count = $hits->count;

    # set up pager
    my $limit = 20;
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
                qw(id journal title number type rank),
                \q[ ts_headline(content, query, 'MaxFragments=2') ],
                qw(journal year volume),
            ],
            as => [
                qw(id journal title number type),
                qw(rank headline),
                qw(journal year volume),
            ],
            from => [
                {
                    xx => $c->model('Dingler::Article')->search(
                        {},
                        {
                            select   => \q[
                                me.id, me.journal, me.title, me.number, me.type, me.content,
                                journal.year, journal.volume,
                                ts_rank_cd(tsv, query) rank, query
                            ],
                            from     => \qq[ article me, journal, $query_func('german', $q) query ],
                            where    => \qq[ query @@ tsv AND me.journal = journal.id $add ],
                            order_by => 'rank DESC',
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
        facets   => \@facets,
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
        $c->stash->{years}{ $1 . "0" }++;
        $c->stash->{types}{ $match->type }++;
    }
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
