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

my $dbh = DBI->connect( 'dbi:Pg:dbname=dingler2', 'fw', 'dingler', { pg_server_prepare => 1, PrintError => 1 } ) or die $DBI::errstr;

my $xml; eval { $xml = XML::LibXML->new->parse_file( '/home/fw/src/kuwi/dingler/database/places/places.xml' ); 1 };
die $@ if $@;
my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
$xpc->registerNs( 'tei', $teins );

$dbh->do( 'DELETE FROM place' ) or die $DBI::errstr;
$dbh->do( "SELECT setval('place_id_seq', 1, false)" ) or die $DBI::errstr;

my $sth = $dbh->prepare( 'INSERT INTO place (plid, place, latitude, longitude) VALUES (?, ?, ?, ?)' ) or die $DBI::errstr;

sub uml { Dingler::Util::uml(@_) }

foreach my $place ( $xpc->findnodes('//tei:place') ) {
    my $plid       = $xpc->find( '@xml:id', $place )."";
    my $coord = uml( $xpc->find( 'tei:location/tei:geo', $place )."" );
    my $place = uml( $xpc->find( 'tei:placeName[1]', $place )."" );
    my ( $lat, $long ) = split /\s+/, $coord;
    $sth->execute( $plid, $place, $lat, $long ) or die $DBI::errstr;
}

$dbh->disconnect;

sub debug {
    print STDERR @_;
}
