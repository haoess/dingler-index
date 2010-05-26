#!/usr/bin/perl

use warnings;
use strict;

use File::Path qw(make_path);
use XML::LibXML;

binmode( STDOUT, ':utf8' );

my $ns_uri = 'http://www.tei-c.org/ns/1.0';
my $parser = XML::LibXML->new();
$parser->load_ext_dtd(0);
$parser->expand_entities(0);

foreach my $file ( @ARGV ) {
    my $journal;
    eval { $journal = $parser->parse_file( $file ); 1 };
    if ( $@ ) {
        debug( "$file: XML-Fehler\n" );
        next;
    };
    my $xpc = XML::LibXML::XPathContext->new( $journal ) or die $!;
    $xpc->registerNs( 'tei', $ns_uri );

    my $journal_id = $xpc->find( '//tei:text[@type="volume"]/@xml:id' );

    my @nodes = $xpc->findnodes( '//tei:text[@type="art_undef" or @type="art_patent"]' );

    my $count = 0;
    foreach my $article ( @nodes ) {
        my $article_id = $article->getAttribute('xml:id');
        my $text = $article->toString;
        savearticle( $journal_id, $article_id, $text );
        $count++;
    }
    debug( sprintf "%s: %3d Artikel\n", $file, $count );
}

sub savearticle {
    my ($jid, $aid, $text) = @_;
    eval { make_path( "var/journals/$jid" ); 1 };
    die $@ if $@;
    open my $fh, '>:utf8', "var/journals/$jid/$aid" or die $!;
    print $fh $text;
    close $fh or die $!;
}

sub debug {
    print STDERR @_;
}
