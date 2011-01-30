#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

my ( $APP, $URL, $REQUEST_COUNT, $leaks );

sub BEGIN {
    $APP           = 'Dingler';
    $URL           = $ARGV[0] || '/';
    $REQUEST_COUNT = $ARGV[1] || 2;
    $leaks         = 0;
    
    eval "use Devel::LeakGuard::Object qw(leakguard)";
    my $leakguard = ! $@;
    eval "use Catalyst::Test '$APP'";
    my $catalyst_test = ! $@;
    
    plan $leakguard && $catalyst_test
    ? ( tests => 2 )
    : ( skip_all => 
        'Devel::LeakGuard::Object and Catalyst::Test
        are needed for this test' ) ;
}

ok( request($URL)->is_success, 'First Request' );

leakguard {
    request($URL) for 1 .. $REQUEST_COUNT;
}
on_leak => sub {
    my $report = shift;
    print "We got some memory leaks: \n";
    for my $pkg ( sort keys %$report ) {
        printf "%s %d %d\n", $pkg, @{ $report->{$pkg} };
    }
    $leaks++;
};

is( $leaks, 0, 'Object Memory Leaks' );
