package Dingler::Controller::Tools::Calc;
use Moose;
use namespace::autoclean;

use JSON;
use Scalar::Util;
use YAML::XS;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Dingler::Controller::Calc - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

open( my $yamlfh, '<', Dingler->path_to( 'calc.yml' ) ) or die $!;
my $yaml = Load do { local $/; <$yamlfh> };

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash( calc => $yaml );
}

sub do :Local {
    my ( $self, $c ) = @_;
    my $value   = $c->req->params->{value};
    my $unit    = $c->req->params->{unit};
    my $section = $c->req->params->{section};
    $value = safe_number( $value );

    my %result;
    while ( my ($key, $formula) = each %{$yaml->{$section}{$unit}{conversions}} ) {
        $formula =~ s/x/$value/g;
        my $result = eval "$formula";
        $result = commify( sprintf( "%.3f", $result ) );
        $result =~ tr/,./ ,/;

        $result{$key} = {
            result => $result,
            wp     => $yaml->{$section}{$key}{wp},
            name   => $yaml->{$section}{$key}{name},
            unit   => $yaml->{$section}{$key}{unit},
        };
    }
    my $json = to_json(\%result);
    utf8::encode( $json );

    $c->res->content_type( 'application/json; charset=utf-8' );
    $c->res->body( $json );
}

sub safe_number {
    my $val = shift;
    $val =~ tr/[0-9,.]//cd;
    $val =~ tr/,/./;
    return Scalar::Util::looks_like_number($val) ? $val : 0;
}

# from The Perl Cookbook, 2.17
sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $text;
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
