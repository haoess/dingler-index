#!/usr/bin/perl

use warnings;
use strict;

use DBI;
use XML::Simple;

my $dbh = DBI->connect( 'dbi:Pg:dbname=dingler', 'fw', 'dingler', { pg_server_prepare => 1, RaiseError => 1 } ) or die $DBI::errstr;

my $xml = XMLin( 'root/static/dingler.xml' )->{event};

my $sth_event = $dbh->prepare( 'INSERT INTO event (title, startyear, startmonth, startday, endyear, endmonth, endday, link, image, description) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)' );
foreach my $e ( @$xml ) {
    no warnings 'uninitialized';
    my ( $sy, $sm, $sd ) = split /-/, $e->{start};
    my ( $ey, $em, $ed ) = split /-/, $e->{end};
    $sth_event->execute( $e->{title}, $sy, $sm, $sd, $ey, $em, $ed, $e->{link}, $e->{image}, $e->{content} );
}
