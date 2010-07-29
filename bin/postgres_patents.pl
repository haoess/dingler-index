#!/usr/bin/perl

binmode( STDOUT, ':utf8' );

use warnings;
use strict;

use utf8;
use lib 'lib';
use Dingler::Util;
use DBI;
use XML::LibXML;

my $dbh = DBI->connect( 'dbi:Pg:dbname=dingler', 'fw', 'dingler' ) or die $DBI::errstr;

my $sth_patent = $dbh->prepare( 'INSERT INTO patent (id, article, subtype, date, xml, content) VALUES (?, ?, ?, ?, ?, ?)' );
my $sth_app    = $dbh->prepare( 'INSERT INTO patent_app (patent, personid, name) VALUES (?, ?, ?)' );

my $parser = XML::LibXML->new;
$parser->expand_entities(0);

JOURNAL:
  foreach my $journal ( @ARGV ) {
    debug( "Processing $journal ...\n" );
    my $xml; eval { $xml = $parser->parse_file( $journal ); 1 };
    if ( $@ ) {
        debug( $@ );
        next JOURNAL;
    }

    my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
    $xpc->registerNs( 'tei', 'http://www.tei-c.org/ns/1.0' );

    foreach my $list ( $xpc->findnodes('//*[@type="art_patents" or @type="misc_patents"]') ) {
        my @data;
        my $articleid = $xpc->find( '@xml:id', $list )."";
        my $subtype   = $xpc->find( '@subtype', $list )."";
        foreach my $patent ( $xpc->findnodes("//*[\@xml:id='$articleid']//tei:div[\@type='patent']") ) {
            my $id   = $xpc->find( '@xml:id', $patent )."";
            my $date = $xpc->find( '*//tei:date/@when', $patent )."" || undef;
            my $content = Dingler::Util::uml( normalize($patent->to_literal) );
            my $xml = $patent->toString;
            $sth_patent->execute( $id, $articleid, $subtype, $date, $xml, $content );

            foreach my $app ( $xpc->findnodes("//*[\@xml:id='$id']//tei:persName[\@role='patent_app']") ) {
                $sth_app->execute( $id, idonly( $xpc->find('@ref'), $app ), Dingler::Util::uml( normalize($app->to_literal) ) );
            }
        }
    }
    debug( '-'x30, "\n" );
}

$dbh->disconnect;

sub normalize {
    my $str = shift || '';
    for ($str) {
        s/\A\s+//;
        s/\s+\z//;
        s/\s+/ /g;
    }
    return $str;
}

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
