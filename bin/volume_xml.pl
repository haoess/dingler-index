#!/usr/bin/perl

use warnings;
use strict;

use Cwd;
use XML::LibXSLT;
use XML::LibXML;

my $svn = '/home/fw/src/kuwi/dingler';

my @volumes = map { s{$svn/}{}; $_ }
              grep { $_ !~ 'pj000' }
              glob "$svn/pj*";

my $journal_xml = "<journals>\n";
foreach my $vol ( @volumes ) {
    $journal_xml .= process_journal($vol);
}

$journal_xml .= "\n</journals>";

print $journal_xml;

sub process_journal {
    my $journal = shift;
    my ($xml) = glob "$svn/$journal/*Z.xml";
    
    XML::LibXSLT->register_function( 'urn:catalyst', 'faclink', \&faclink );
    XML::LibXSLT->register_function( 'urn:catalyst', 'uml', \&uml );
    
    my $source     = XML::LibXML->load_xml( location => $xml );
    my $style_doc  = XML::LibXML->load_xml( location => getcwd . '/root/xslt/journal-list-pre.xsl', no_cdata => 1 );
    my $stylesheet = XML::LibXSLT->new
                                 ->parse_stylesheet( $style_doc );

    my %params  = XML::LibXSLT::xpath_to_string( journal => $journal  );
    my $results = $stylesheet->transform( $source, %params );
    
    return $stylesheet->output_as_bytes( $results );
}

sub faclink {
    my $id = shift;
    $id =~ /(\w+)(?:\/(\w+))?/;
    my $ret = "http://www.polytechnischesjournal.de/journal/dinger-online/?tx_slubdigitallibrary[ppn]=$1";
    if ( defined $2 ) {
        $ret .= "&tx_slubdigitallibrary[image]=$2";
    }
    return $ret;
}

sub uml {
    my $str = shift || '';
    for ($str) {
        s/a\x{0364}/ä/g;
        s/o\x{0364}/ö/g;
        s/u\x{0364}/ü/g;
        s/\s+/ /g;
    }
    return $str;
}
