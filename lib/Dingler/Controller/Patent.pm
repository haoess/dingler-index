package Dingler::Controller::Patent;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use Scalar::Util qw(weaken);

use utf8;
my @langmap = (
    [ qw(english England) ],
    [ qw(french Frankreich) ],
    [ qw(austrian Österreich) ],
    [ qw(prussian Preußen) ],
    [ qw(scottish Schottland) ],
    [ qw(american USA) ],
);

=head1 NAME

Dingler::Controller::Patent - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 auto

=cut

sub auto :Private {
    my ( $self, $c ) = @_;
    $c->stash( langmap => \@langmap );
    $c->stash(
        render_patent => sub {
            my ( $id, $xml ) = @_;

            my $cache = Cache::FileCache->new({
                cache_root => $c->path_to( 'var', 'cache' )."",
                namespace  => 'dingler-patents'
            });
            my $xsl = $cache->get( $id );
            if ( not defined $xsl ) {
                $c->stash(
                    id       => $id,
                    template => 'unit.xsl',
                    xml      => $xml,
                );
                $c->forward('Dingler::View::XSLT');
                $xsl = $c->res->body;
                utf8::decode($xsl);
                $c->res->body( undef );
            }
            $cache->set( $id, $xsl );
            return $xsl;
        },
    );
    return 1;
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $search = {};

    if ( my $subtype = $c->req->params->{subtype} ) {
        $search->{subtype} = $subtype;
    }

    if ( my $decade = $c->req->params->{decade} ) {
        $search->{date} = { -between => [ "$decade-01-01", ($decade+9)."-12-31" ] };
    }

    if ( keys %$search ) {
        $c->forward('build_rs', [$search]);
        $c->stash( template => 'patent/list.tt' );
    }
    else {
        $c->stash( template => 'patent/index.tt' );
    }
}

=head2 build_rs

=cut

sub build_rs :Private {
    my ( $self, $c, $search ) = @_;
    my $limit = 20;
    my $page = $c->req->params->{p} || 1;
    $page = 1 if $page !~ /\A[0-9]+\z/;
    my $pager = Data::Page->new;
    $pager->total_entries( $c->model('Dingler::Patent')->search( $search )->count );
    $pager->entries_per_page( $limit );
    $pager->current_page( $page );

    my $rs = $c->model('Dingler::Patent')->search( $search );

    while ( my $match = $rs->next ) {
        my $subtype = $match->subtype;
        $c->stash->{facet}{subtype}{$subtype}++;

        my $date = $match->get_column('date');
        if ( $date ) {
            $date =~ /\A(\d{3})/;
            $c->stash->{facet}{decade}{$1}++;
        }
    }
    $rs->reset; # don't forget

    $rs = $rs->search(
        $search,
        {
            order_by => 'date',
            rows     => $limit,
            offset   => ($page - 1) * $limit,
        }
    );
    $c->stash(
        pager => $pager,
        rs    => $rs,
    );
}

=head2 search

=cut

sub search :Local {
    my ( $self, $c ) = @_;

    my $dbh = $c->model('Dingler::Patent')->result_source->schema->storage->dbh;

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
    # subtypes to search in
    my @st = grep { defined } ref $c->req->params->{subtype} ? @{$c->req->params->{subtype}} : $c->req->params->{subtype};
    my @add;
    foreach my $subtype ( @st ) {
        push @add, 'me.subtype = ' . $dbh->quote($subtype) if grep { $_->[0] eq $subtype } @langmap;
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
    my $hits = $c->model('Dingler::Patent')->search(
        { },
        {
            select => [ 'me.id', 'me.subtype', 'me.date', 'journal.year' ],
            as     => [ 'id', 'subtype', 'date', 'year' ],
            from   => \qq[ patent me, $query_func('german', $q) query, article article, journal journal ],
            where  => \qq[ query @@ me.tsv AND me.article = article.id AND article.journal = journal.id $add_to_where ],
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
    my $matches = $c->model('Dingler::Patent')->search(
        {},
        {
            select => [
                qw(id date xml),
            ],
            as => [
                qw(id date xml),
            ],
            from => [
                {
                    xx => $c->model('Dingler::Patent')->search(
                        {},
                        {
                            select   => \qq[
                                me.id, me.date, me.xml,
                                ts_rank_cd(me.tsv, query) rank, query
                            ],
                            from     => \qq[ patent me, article, journal, $query_func('german', $q) query ],
                            where    => \qq[ query @@ me.tsv AND me.article = article.id AND article.journal = journal.id $add_to_where ],
                            order_by => $order_by,
                            rows     => $limit,
                            offset   => ($page - 1) * $limit,
                        }
                    )->as_query,
                },
            ],
        },
    );

#    $c->forward('facets', [$hits]);

    $c->stash(
        template => 'patent/result.tt',
        q        => $search,
        pager    => $pager,
        matches  => $matches,
    );
}

=head2 XXX

=cut

sub sineapp :Local {
    my ( $self, $c, $subtype ) = @_;

    my $rs = $c->model('Dingler::Patent')->search(
        {
            'patent_apps.id' => undef,
        },
        {
            order_by => 'date',
            join => [ 'patent_apps' ],
            rows => 20,
        }
    );

    $c->stash(
        rs      => $rs,
    );
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
