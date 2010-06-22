package Dingler::Controller::Search;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

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

    my $query_func = 'to_tsquery';
    {
        # test query if it fits to to_tsquery
        eval { $dbh->do( "SELECT to_tsquery($q)" ); 1 };
        $query_func = 'plainto_tsquery' if $@;
    }

    my $matches = $c->model('Dingler::Article')->search(
        {
        },
        {
            '+select' => [
                \q[ ts_headline(content, query, 'MaxFragments=2') ],
                \q[ ts_rank_cd(tsv, query) rank ],
            ],
            '+as' => [ 'headline', 'rank' ],
            from => \qq[ article me, $query_func('german', $q) query, journal ],
            where => \q[ query @@ tsv AND me.journal = journal.id ],
            order_by => 'rank DESC',
            #rows => 20,
        },
    );

    my %years;
    while ( my $match = $matches->next ) {
        $years{ $match->journal->year }++;
    }
    $matches->reset;

    my %types;
    while ( my $match = $matches->next ) {
        $types{ $match->type }++;
    }
    $matches->reset;

    $c->stash(
        template => 'search/result.tt',
        matches => $matches,
        q => $search,
        years => \%years,
        types => \%types,
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
