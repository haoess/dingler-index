package Dingler::Controller::Search;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use utf8;
use Data::Page;
use Digest::MD5 qw( md5_hex );
use Sphinx::Search;

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
#    [ idx     => 'Register',           'XXX' ],
#    [ add     => 'Hg.-Ergänzung',      'XXX' ],
#    [ other   => 'Sonstiges',          'XXX', 'YYY' ], # Vorworte, Widmungen, Anzeigen etc.
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

    my $query = $c->req->params->{q};
    my @query_words = map   { s/^=//; s/\*$//; $_ }
                      grep  { !/^[@!-]/ && !/^[&|]$/ }
                      split /\s+/, $query;

    ###################################
    # paging
    my $limit = 20;
    my $page = $c->req->params->{p} || 1;
    $page = 1 if $page !~ /\A[0-9]+\z/;

    ###################################
    # sorts of text to search in
    my @ts = grep { defined } ref $c->req->params->{ts} ? @{$c->req->params->{ts}} : $c->req->params->{ts};
    my @ts_fields;
    foreach my $texttype ( @ts ) {
        push @ts_fields, map { @$_[2 .. $#$_] }
                         grep { $_->[0] eq $texttype } @texttypes;
    }

    ###################################
    # period of time
    my $from = $c->req->params->{from};
    my $to   = $c->req->params->{to};

    ###################################
    # result sorting
    my $sort = $c->req->params->{sort} || 'rank';
    $c->stash->{sort} = $sort;
    # TODO: sort by author
    my @order_by = $sort eq 'title'  ? (SPH_SORT_ATTR_ASC, 'i_title')
                 : $sort eq 'year'   ? (SPH_SORT_ATTR_ASC, 'i_year')
                 :                     (SPH_SORT_RELEVANCE);

    # finished setup
    my $sph = Sphinx::Search->new({ port => 9312, debug => 1 });

    # find all matching documents
    $sph->SetMatchMode( SPH_MATCH_EXTENDED2 )
        ->SetSortMode( @order_by )
        ->SetLimits( ($page - 1) * $limit, $limit )
        ->SetFieldWeights({ title => 1, content => 4 });
    $sph->SetFilter( 'i_type', [ map { hex(substr( md5_hex($_), 0, 7 )) } @ts_fields ] ) if @ts_fields;
    $sph->SetFilterRange( 'i_year', $from, $to ) if $from && $to;
    my $result = $sph->Query( $query );

    my $count = $result->{total_found};

    my @id_list = map { $_->{doc} } @{$result->{matches}};
    my $matches = $c->model('Dingler::Article')->search(
        {
            uid => { -in => \@id_list },
        },
        {
            order_by => \qq~find_in_array( uid, '{@{[ join(",", @id_list) ]}}' )~,
        },
    );

    # grouping: year
    $sph->ResetFilters
        ->ResetGroupBy
        ->ResetOverrides
        ->SetMatchMode( SPH_MATCH_EXTENDED2 )
        ->SetGroupBy( 'i_year', SPH_GROUPBY_ATTR )
        ->SetLimits( 0, 1940 - 1820 ); # pass by the default of 20 returned results
    $sph->SetFilter( 'i_type', [ map { hex(substr( md5_hex($_), 0, 7 )) } @ts_fields ] ) if @ts_fields;
    $sph->SetFilterRange( 'i_year', $from, $to ) if $from && $to;
    $result = $sph->Query( $query );

    foreach my $match ( @{$result->{matches}} ) {
        my $year = $c->model('Dingler::Article')->find( $match->{doc} )->journal->year;
        $year =~ /\A([0-9]{3})/;
        $c->stash->{facet}{decade}{ $1 } += $match->{'@count'};
        $c->stash->{facet}{year}{ $year } += $match->{'@count'};
    }
    foreach my $decade ( 182 .. 193 ) {
        $c->stash->{facet}{decade}{ $decade } = 0 unless $c->stash->{facet}{decade}{ $decade };
    }
    foreach my $year ( 1820 .. 1931 ) {
        $c->stash->{facet}{year}{ $year } = 0 unless $c->stash->{facet}{year}{ $year };
    }

    # grouping: type
    $sph->ResetFilters
        ->ResetGroupBy
        ->ResetOverrides
        ->SetMatchMode( SPH_MATCH_EXTENDED2 )
        ->SetGroupBy( 'i_type', SPH_GROUPBY_ATTR );
    $sph->SetFilter( 'i_type', [ map { hex(substr( md5_hex($_), 0, 7 )) } @ts_fields ] ) if @ts_fields;
    $sph->SetFilterRange( 'i_year', $from, $to ) if $from && $to;
    $result = $sph->Query( $query );

    foreach my $match ( @{$result->{matches}} ) {
        my $type = $c->model('Dingler::Article')->find( $match->{doc} )->type;
        $c->stash->{facet}{texttype}{ $tt_reverse{$type} } += $match->{'@count'};
    };

    # set up pager
    my $pager = Data::Page->new;
    $pager->total_entries( $count );
    $pager->entries_per_page( $limit );
    $pager->current_page( $page );

    $c->stash(
        template => 'search/result.tt',
        q        => $query,
        pager    => $pager,
        matches  => $matches,
        excerpt  => sub {
            my $content = shift;
            my $excerpt = $sph->BuildExcerpts( [$content], 'dingler', join( ' ', @query_words ) );
            return $excerpt->[0];
        },
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
