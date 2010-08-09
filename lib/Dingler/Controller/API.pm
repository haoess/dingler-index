package Dingler::Controller::API;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Dingler::Controller::API - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->response->body('Matched Dingler::Controller::API in API.');
}

sub tabular :Local {
    my ( $self, $c ) = @_;
    my $rs = $c->model('Dingler::Figure')->search( undef, {
        'select' => 'url',
        group_by => 'url',
        order_by => 'url',
    } );
    my @tabulars;
    my %vol_seen;
    while ( my $tabular = $rs->next ) {
        my ($journal) = $tabular->url =~ /(pj\d+)/;
        $journal = $c->uri_for( '/journal', $journal );

        my ($volume) = $journal =~ /(\d+)/;
        $vol_seen{$volume}++;
        my $name = sprintf 'Band %d, Tafel %d', $volume, $vol_seen{$volume};

        # http://www.culture.hu-berlin.de/dingler_static/pj001/image_markup/tab001537_wv_tab001537.jpg
        # =>
        # http://www.culture.hu-berlin.de/dingler_static/pj001/thumbs/tab001537_250.jpg
        my $url = $tabular->url;
        $url =~ s/image_markup\/(tab\d{6}).*/thumbs\/$1_/;
        $name .= " ($1)";

        push @tabulars, {
            url     => $url,
            name    => $name,
            journal => $journal,
        };
    }
    $c->stash(
        tabulars => \@tabulars,
        template => 'api/tabular.tt',
    );
    $c->res->content_type( 'application/atom+xml' );
    $c->forward('Dingler::View::Plain');
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
