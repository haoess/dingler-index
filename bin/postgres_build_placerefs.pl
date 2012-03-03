#!/usr/bin/perl

binmode( STDOUT, ':utf8' );

use warnings;
use strict;

use utf8;
use lib 'lib';
use Dingler::Util;
use DBI;
use XML::LibXML;

my $teins = 'http://www.tei-c.org/ns/1.0';

my $dbh = DBI->connect( 'dbi:Pg:dbname=dingler', '', '', { pg_server_prepare => 1, PrintError => 1 } ) or die $DBI::errstr;

my $sth_article = $dbh->prepare( 'SELECT uid, id, type FROM article WHERE id = ?' );
my $sth_place = $dbh->prepare( 'INSERT INTO placeref (article, place) VALUES (?, ?)' );

JOURNAL:
  foreach my $journal ( @ARGV ) {
    debug( "Processing $journal ...\n" );
    my $xml; eval { $xml = XML::LibXML->new->parse_file( $journal ); 1 };
    if ( $@ ) {
        debug( $@ );
        next JOURNAL;
    }
    my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
    $xpc->registerNs( 'tei', $teins );

    foreach my $article ( $xpc->findnodes('//tei:text[@type="art_undef" or @type="art_patent" or @type="art_miscellanea" or @type="art_patents" or @type="art_literature"]') ) {
        my $id = $xpc->find( '@xml:id', $article );
        my $uid = $dbh->selectcol_arrayref( $sth_article, undef, $id )->[0];
        $dbh->do( 'DELETE FROM placeref WHERE article = ?', undef, $uid );
        foreach my $place ( $xpc->findnodes('*//tei:placeName', $article) ) {
            my $ref = idonly( $xpc->find('@ref', $place) );
            next if $ref eq '-';
            $sth_place->execute( $uid, $ref );
        }

        my $type = $xpc->find( '@type', $article ) . "";
        if ( $type eq 'art_miscellanea' ) {
            foreach my $misc ( $xpc->findnodes('//tei:text[@xml:id="' . $id . '"]//tei:div[@type="misc_undef" or @type="misc_patents"]') ) {
                my $miscid  = $xpc->find( '@xml:id', $misc );
                $uid = $dbh->selectcol_arrayref( $sth_article, undef, $miscid )->[0];
                $dbh->do( 'DELETE FROM placeref WHERE article = ?', undef, $uid );
                foreach my $place ( $xpc->findnodes('//*[@xml:id="' . $miscid . '"]//tei:placeName') ) {
                    my $ref = idonly( $xpc->find('@ref', $place) );
                    next if $ref eq '-';
                    $sth_place->execute( $uid, $ref );
                }
            }
        }
    }
    debug( '-'x30, "\n" );
}

$dbh->disconnect;

sub idonly {
    my $id = shift;
    $id =~ s/.*#//;
    if ( !$id ) {
        return '-';
    }
    else {
        return $id;
    }
}

sub debug {
    print STDERR @_;
}
