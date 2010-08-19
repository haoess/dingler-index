package Dingler::Controller::Timeline;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use utf8;
use File::Temp qw(tempfile);
use File::Basename qw(basename);

=head1 NAME

Dingler::Controller::Timeline - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    my $search = $c->req->params->{q};

    my $dbh = $c->model('Dingler::Article')->result_source->schema->storage->dbh;
    my $q = $dbh->quote($search);

    # test query if it fits to to_tsquery
    my $query_func = 'to_tsquery';
    eval { $dbh->do( "SELECT to_tsquery($q)" ); 1 };
    $query_func = 'plainto_tsquery' if $@;

    my $hits = $c->model('Dingler::Article')->search(
        { },
        {
            select => [ 'me.id', 'journal.id', 'me.title', 'journal.year' ],
            as     => [ 'id', 'jid', 'title', 'year' ],
            from   => \qq[ article me, $query_func('german', $q) query, journal journal ],
            where  => \qq[ query @@ tsv AND me.journal = journal.id AND me.type NOT IN ('art_miscellanea', 'misc_undef', 'art_patents', 'misc_patents') ],
        }
    );

    my $xml = "<data>\n";
    while ( my $hit = $hits->next ) {
        my $title = $hit->get_column('title');
        for ( $title ) {
            s/\A\w+'s,? (?:und \w+'s )?//;
            s/\Av\. \w+, (?:(?:ue|ü)ber )?//;
            s/\A[Uu]eber //;
            s/\A\w+, über //;
            s/\A(?:das|die|den|ein(?: neues)?|einen|einiges über) //i;
            s/\.$//;
            $title = ucfirst;
        }
        $xml .= sprintf '  <event start="%s" title="%s" link="http://admin.culture.hu-berlin.de/dingler/article/%s/%s"></event>%s',
                    $hit->get_column('year'), $title, $hit->get_column('jid'), $hit->get_column('id'), "\n";
    }
    $xml .= "</data>";

    my ($tempfh, $tempname) = tempfile(
        DIR    => $c->path_to('var', 'timeline-search'),
        SUFFIX => '.xml',
        UNLINK => 0,
    );
    binmode( $tempfh, ':utf8' );
    print $tempfh $xml;
    close $tempfh;

    $c->stash(
        template => 'timeline/search.tt',
        q        => $q,
        tlxml    => basename($tempname),
    );
}

=head2 dta

=cut

sub dta :Local {
    my ( $self, $c, $year ) = @_;
    $c->stash(
        template => 'timeline/dta.tt',
        year     => $year,
    );
}

=head2 patent

=cut

sub patent :Local {
    my ( $self, $c, $year ) = @_;
    $c->stash(
        template => 'timeline/patent.tt',
        year     => $year,
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
