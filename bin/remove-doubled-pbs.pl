#!/usr/bin/perl

use warnings;
use strict;

use File::Path qw( make_path );
use File::Slurp qw( read_file write_file );
use Getopt::Long;

GetOptions(
    'o=s' => \my $outdir,
);
die unless $outdir;
make_path( $outdir );

foreach my $file ( @ARGV ) {
    my ( $journal ) = $file =~ /(pj\d+)/;
    my $xml = read_file( $file );
    $xml =~ s/<pb[^>]+"[^"]+_n\d+"\/>//g;
    write_file( "$outdir/$journal.xml", $xml );
}
