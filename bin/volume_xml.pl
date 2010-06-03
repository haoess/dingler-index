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
    my $xslt = XML::LibXSLT->new;
    XML::LibXSLT->register_function( 'urn:catalyst', 'faclink', \&faclink );
    my $source = XML::LibXML->load_xml( location => $xml );
    my $style_doc = XML::LibXML->load_xml( location => getcwd . '/root/xslt/journal-list-pre.xsl', no_cdata => 1 );
    my $stylesheet = $xslt->parse_stylesheet( $style_doc );
    my $results = $stylesheet->transform( $source, journal => $journal );
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
