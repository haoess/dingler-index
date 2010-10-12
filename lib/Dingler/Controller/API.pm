package Dingler::Controller::API;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Dingler::Controller::API - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 tabular

=cut

sub tabular :Local {
    my ( $self, $c ) = @_;
    my $rs = $c->model('Dingler::Figure')->search(
        {
            reftype => 'tabular',
        },
        {
            'select' => 'ref',
            group_by => 'ref',
            order_by => 'ref',
        }
    );
    my @tabulars;
    my %vol_seen;
    while ( my $tabular = $rs->next ) {
        my ($volume) = $tabular->ref =~ /tab(\d{3})/;
        my $journal = "pj$volume";

        $vol_seen{$volume}++;
        my $name = sprintf 'Band %d, Tafel %d (%s)', $volume, $vol_seen{$volume}, $tabular->ref;

        push @tabulars, {
            ref     => $tabular->ref,
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
