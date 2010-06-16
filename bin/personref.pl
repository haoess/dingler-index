#!/usr/bin/perl

# output of this script should go into var/ptrs.xml

use warnings;
use strict;

use XML::LibXSLT;
use XML::LibXML;
use XML::Simple;

my $svn = '/home/fw/src/kuwi/dingler';

my $libxslt = XML::LibXSLT->new;
$libxslt->register_function( 'urn:catalyst', 'idonly', \&idonly );

my $out;

JOURNAL:
  foreach my $journal ( glob "$svn/*/*Z.xml" ) {
    debug( "Processing $journal ...\n" );
    my $source;
    eval { $source = XML::LibXML->load_xml( location => $journal ); 1 };
    if ( $@ ) {
        debug( $@, "\n" );
        next JOURNAL;
    }
    my $style_doc  = XML::LibXML->load_xml( location => 'root/xslt/person-ref.xsl' );
    my $stylesheet = $libxslt->parse_stylesheet( $style_doc );
    my $results    = $stylesheet->transform( $source );
    $out .= $stylesheet->output_as_bytes( $results );
}

my $source = XMLin( '<?xml version="1.0" encoding="UTF-8"?><ptrs>' . $out . '</ptrs>' ) or die $!;

# these two loops should be merged into one
my %res;
foreach my $ptr ( @{ $source->{ptr} } ) {
    push @{ $res{ $ptr->{person} } }, $ptr->{article};
}
my @res2;
while ( my ($key, $value) = each %res ) {
    push @res2, {
        person => $key,
        'ref'  => $value,
    };
}

print XMLout( { ptr => \@res2 }, RootName => 'ptrs' );

sub idonly {
    my $id = shift;
    $id =~ s/.*#//;
    if ( !$id || $id.'' eq 'pers' ) {
        return '-';
    }
    else {
        return $id;
    }
}

sub debug {
    print STDERR @_;
}
