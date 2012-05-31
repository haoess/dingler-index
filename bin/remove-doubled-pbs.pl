#!/usr/bin/perl

use warnings;
use strict;

use File::Path qw( make_path );
use Getopt::Long;

GetOptions(
    'o=s' => \my $outdir,
);
die unless $outdir;

make_path( $outdir );

my %pb_seen;

foreach my $file ( @ARGV ) {
    my ( $journal ) = $file =~ /(pj\d+)/;
    open( my $infh, '<:utf8', $file ) or die $!;
    my $xml = do { local $/; <$infh> };
    close $infh;

    $xml =~ s{\R*(<pb\b[^>]*facs="\w+/(\d{8})"[^>]*>)\R*}{_pb( $1, $2 )}ge;

    open( my $outfh, '>:utf8', "$outdir/$journal.xml" ) or die $!;
    print $outfh $xml;
    close $outfh or die $!;

    %pb_seen = ();
}

sub _pb {
    my ( $pb, $facs ) = @_;
    return '' if exists $pb_seen{$facs};
    $pb_seen{$facs}++;
    return $pb;
}
