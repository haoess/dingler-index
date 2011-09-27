#!/usr/bin/perl

use 5.010;
use warnings;

binmode( STDOUT, ':utf8' );

use Data::Dumper;
use DBI;

my $dbh = DBI->connect( 'dbi:Pg:dbname=ddc', 'fw', 'dingler', { pg_enable_utf8 => 1, PrintError => 1 } )
    or die $DBI::errstr;

my $word = shift;

my $sth  = $dbh->prepare( 'SELECT * FROM ddc WHERE object = ? AND predicate = ?' );
my $sth2 = $dbh->prepare( 'SELECT * FROM ddc WHERE subject = ? AND predicate = ?' );

$sth->execute( $word, 'http://www.w3.org/2004/02/skos/core#prefLabel' );
while ( my $row = $sth->fetchrow_hashref ) {
    $sth2->execute( $row->{subject}, 'http://d-nb.info/hasCoordinatedConcept-of' );
    while( my $r = $sth2->fetchrow_hashref ) {
        say Dumper $dbh->selectrow_hashref( 'SELECT * FROM ddc WHERE subject = ?', undef, $r->{object} );
    }
    say "-"x40;
}
