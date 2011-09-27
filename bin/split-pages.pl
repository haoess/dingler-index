#!/usr/bin/perl

use warnings;
use strict;

use File::Path qw( make_path );
use Getopt::Long;
use XML::Parser::Expat;

my @tags;           # "stack": encountered tags (append start elements and delete them when end elements are encountered)
my @pages;          # list: all pages
my $empty_tag = 0;       # boolean: the current tag is probably empty or not
my $after_head = 0;      # boolean: we are after the file's head element or not
my $page_started = 0;    # boolean: the first page has already started or not
my $headname = "teiHeader";   # string: the name for the file's head element

GetOptions(
    'f=s' => \my $infile,
    'o=s' => \my $outdir,
);

my $expat = XML::Parser::Expat->new( ProtocolEncoding => 'UTF-8' );
$expat->setHandlers(
    Start   => \&start_element,
    End     => \&end_element,
    Char    => \&char_data,
    Comment => \&comment_data,
);

eval { $expat->parsefile( $infile ); 1 };
die $@ if $@;

my $pb_number = 1;

eval { make_path( $outdir ); 1 };
die $@ if $@;
    
# now go through all generated pages
foreach my $page ( @pages ) {
    open( my $pagefh, '>:utf8', sprintf( "%s/%04d.xml", $outdir, $pb_number ) ) or die $!;
    print $pagefh $page or die $!;
    close $pagefh or die $!;
    $pb_number++;
}

#################################

# function to handle start elements
sub start_element {
    my ( $parser, $el, %attrs ) = @_;
    push @tags, [ $el, \%attrs ];
    return unless $after_head;

    if ( page_starts_here($el, %attrs) ) {
        $page_started = 1;

        if ( @pages ) {
            # close tags that are still open at the end of the current page
            for my $i ( 1 .. scalar(@tags)-1 ) {
                my $page = '</' . $tags[ scalar(@tags) - 1 - $i ]->[0] . '>';
                $pages[-1] .= $page;
            }
        }
        push @pages, '';

        foreach my $entry ( @tags ) {# (name2,attrs2) in tags:
            # open tags that were opened before this page started
            my $tag = '<' . $entry->[0];
            while ( my ($att, $val) = each %{ $entry->[1] } ) {
                $tag .= sprintf ' %s="%s"', $att, $val;
            }
            $tag .= '>';
            $pages[-1] .= $tag;
        }
    }
    elsif ( $after_head and $page_started ) {
        # a tag within a page that is no pagebreak element is treated here: Just add it to the current page
        my $tag = '<' . $el;
        while ( my ($att, $val) = each %attrs ) {
            $tag .= sprintf ' %s="%s"', $att, $val;
        }
        $tag .= '>';
        $pages[-1] .= $tag;
    }
    $empty_tag = 1;
}

# function to handle end elements
sub end_element {
    my ( $parser, $name ) = @_;
    pop @tags;

    my $just_switched_after_head = 0;
    if ( $name eq $headname ) {
        $after_head = 1;
        $just_switched_after_head = 1;
    }
    return unless $after_head;
    
    if ( !$empty_tag and !$just_switched_after_head ) {
        # handle non-empty tags
        eval {
            $pages[-1] .= '</' . $name . '>';
        };
    }
    elsif ( !$just_switched_after_head ) {
        # handle empty tags
        eval {
            $pages[-1] =~ s{<([^>]*)>$}{<$1/>}g;
        };
    }
    $empty_tag = 0;
}

# function to handle character data
sub char_data {
    my ( $parser, $data ) = @_;
    $empty_tag = 0;

    if ( not $after_head or not $data ) {
        return;
    }
    # just add the character data to the current page if appropriate
    if ( @pages ) {
        $data =~ s/&/&amp;/g;
        $data =~ s/</&lt;/g;
        $data =~ s/>/&gt;/g;
        $pages[-1] .= $data;
    }
}

# function to handle comments
sub comment_data {
    my ( $parser, $data ) = @_;
    $empty_tag = 0;

    if ( not $after_head or not $data ) {
        return;
    }
    if ( @pages ) {
        # just add the comment data to the current page if appropriate
        $pages[-1] .= '<!-- ' . $data . ' -->';
    }
}

# function to determine, depending on the current mode, if the current tag is a pb element or not
sub page_starts_here {
    my ( $name, $attrs ) = @_;
    return $name eq "pb";
}
