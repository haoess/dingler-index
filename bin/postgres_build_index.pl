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

JOURNAL:
  foreach my $journal ( @ARGV ) {
    debug( "Processing $journal ...\n" );
    my $xml; eval { $xml = XML::LibXML->new->parse_file( $journal ); 1 };
    if ( $@ ) {
        debug( $@ );
        next JOURNAL;
    }
    my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
    $xpc->registerNs( 'tei', 'http://www.tei-c.org/ns/1.0' );
    
    my ($jid)     = $journal =~ /(pj[0-9]{3})/;
    my $year      = $xpc->find( '//tei:imprint/tei:date' );
    my $volume    = $xpc->find( '//tei:imprint/tei:biblScope' );
    my $facsimile = $xpc->find( '//tei:sourceDesc//tei:idno' );
    my $j_facsimile = Dingler::Util::faclink($facsimile);
    
    my $sth = $dbh->prepare( 'INSERT INTO journal(id, volume, year, facsimile) VALUES (?, ?, ?, ?)' );
    $sth->execute( $jid, $volume, $year, $j_facsimile );
    
    my $pos = 1;
    foreach my $article ( $xpc->findnodes('//tei:text[@type="art_undef" or @type="art_patent" or @type="art_misc"]') ) {
        my $id     = $xpc->find( '@xml:id', $article );
        my $type   = $xpc->find( '@type', $article );
        my $number = $xpc->find( 'tei:front/tei:titlePart[@type="number"]', $article );
        my $title  = $xpc->find( 'tei:front/tei:titlePart[@type="column"]', $article );
        $title = Dingler::Util::uml(normalize($title->to_literal));

        my $pagestart = $xpc->find( 'tei:front/tei:pb[1]/@n', $article ) || $xpc->find( 'preceding::tei:pb[1]/@n', $article );
        my $pageend = $xpc->find( 'following::*[1]/preceding::tei:pb[1]/@n', $article);

        my $ar_facsimile = $xpc->find( 'tei:front/tei:pb[1]/@facs', $article) || $xpc->find( 'preceding::tei:pb[1]/@facs', $article );
        $ar_facsimile = Dingler::Util::faclink($ar_facsimile);

        my $body   = $xpc->find( 'tei:body', $article );
        $body = Dingler::Util::uml(normalize($body->to_literal));

        $sth = $dbh->prepare( 'INSERT INTO article(id, journal, type, volume, number, title, pagestart, pageend, facsimile, content, position) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)' );
        $sth->execute( $id, $jid, $type, $volume, $number, $title, $pagestart, $pageend, $ar_facsimile, $body, $pos );

        foreach my $figure ( $xpc->findnodes('.//tei:ref[starts-with(@target, "#tab")]', $article) ) {
            $sth = $dbh->prepare( 'INSERT INTO figure (article, url) VALUES (?, ?)' );
            my $figlink = Dingler::Util::figlink( $xpc->find('@target', $figure), $facsimile );
            $sth->execute( $id, $figlink );
        }
        $pos++;
    }

    my %refs;
    foreach my $persname ( $xpc->findnodes('//tei:titlePart[@type="main"]/tei:persName') ) {
        push @{ $refs{ idonly($xpc->find('@ref', $persname)) } }, $xpc->find('ancestor::tei:text[1]/@xml:id', $persname)."";
    }
    foreach my $persname ( $xpc->findnodes('//tei:div[@type="misc_undef"]//tei:head/tei:persName') ) {
        push @{ $refs{ idonly($xpc->find('@ref', $persname)) } }, $xpc->find('ancestor::tei:text[1]/@xml:id', $persname)."";
    }
    while ( my ($k, $v) = each %refs ) {
        next if $k eq '-';
        foreach my $ref ( @$v ) {
            $sth = $dbh->prepare( 'INSERT INTO person (id, ref) VALUES (?, ?)' );
            $sth->execute( $k, $ref );
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
