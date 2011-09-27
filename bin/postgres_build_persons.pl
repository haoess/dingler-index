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

my $xml; eval { $xml = XML::LibXML->new->parse_file( '/home/fw/src/kuwi/dingler/database/persons/persons.xml' ); 1 };
die $@ if $@;
my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
$xpc->registerNs( 'tei', $teins );

$dbh->do( 'DELETE FROM person' ) or die $DBI::errstr;
$dbh->do( "SELECT setval('person_uid_seq', 1, false)" ) or die $DBI::errstr;

my $sth = $dbh->prepare( 'INSERT INTO person (id, rolename, addname, forename, namelink, surname, pnd, viaf) VALUES (?, ?, ?, ?, ?, ?, ?, ?)' ) or die $DBI::errstr;

sub uml { Dingler::Util::uml(@_) }

foreach my $person ( $xpc->findnodes('//tei:person') ) {
    my $id       = $xpc->find( '@xml:id', $person )."";
    my $rolename = uml( $xpc->find( 'tei:persName/tei:roleName[1]', $person )."" );
    my $addname  = uml( $xpc->find( 'tei:persName/tei:addName[1]', $person )."" );
    my $forename = uml( $xpc->find( 'tei:persName/tei:forename[1]', $person )."" );
    my $namelink = uml( $xpc->find( 'tei:persName/tei:nameLink[1]', $person )."" );
    my $surname  = uml( $xpc->find( 'tei:persName/tei:surname[1]', $person )."" );
    my $pnd      = uml( $xpc->find( 'tei:note[@type="pnd"][1]', $person )."" );
    my $viaf     = uml( $xpc->find( 'tei:note[@type="viaf"][1]', $person )."" );
    $sth->execute( $id, $rolename, $addname, $forename, $namelink, $surname, $pnd, $viaf ) or die $DBI::errstr;
}

$dbh->disconnect;

sub debug {
    print STDERR @_;
}
