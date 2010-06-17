#!/usr/bin/perl

# output of this script should go into var/volumes.xml

use lib 'lib';

use utf8;

use warnings;
use strict;

use Cwd;
use Dingler::Util;
use XML::LibXSLT;
use XML::LibXML;

my $svn = '/home/fw/src/kuwi/dingler';

my @volumes = map { s{$svn/}{}; $_ }
              grep { $_ !~ 'pj000' }
              glob "$svn/pj*";

my $journal_xml = "<?xml version='1.0' encoding='UTF-8'?>\n<journals>\n";
foreach my $vol ( @volumes ) {
    debug( "Verarbeite $vol ...\n" );
    $journal_xml .= process_journal($vol);
}
$journal_xml .= "\n</journals>";

print $journal_xml;

sub process_journal {
    my $journal = shift;
    my ($xml) = glob "$svn/$journal/*Z.xml";

    XML::LibXSLT->register_function( 'urn:catalyst', 'faclink', \&faclink );
    XML::LibXSLT->register_function( 'urn:catalyst', 'uml', \&Dingler::Util::uml );

    my $source;
    eval { $source = XML::LibXML->load_xml( location => $xml ); 1 };
    if ( $@ ) {
        debug( $@, "\n" );
        return '';
    }
    my $style_doc  = XML::LibXML->load_xml( location => getcwd . '/root/xslt/journal-list-pre.xsl', no_cdata => 1 );
    my $stylesheet = XML::LibXSLT->new
                                 ->parse_stylesheet( $style_doc );
    my %params     = XML::LibXSLT::xpath_to_string( journal => $journal  );
    my $results    = $stylesheet->transform( $source, %params );

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

sub debug {
    print STDERR @_;
}
