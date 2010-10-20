package Dingler::Controller::Root;
use Moose;
use namespace::autoclean;

use Cache::FileCache;
use XML::Simple;

BEGIN { extends 'Catalyst::Controller' }

# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
__PACKAGE__->config(namespace => '');

=head1 NAME

Dingler::Controller::Root - Root Controller for Dingler

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 auto

=cut

sub auto :Private {
    my ($self, $c) = @_;
    $c->stash(
        base => $c->req->base,
        requri => $c->req->uri,
    );

    $c->stash->{volumes} = [
        map { s/@{[$c->config->{svn}]}\///; $_ }
        grep { $_ !~ 'pj000' }
        glob $c->config->{svn} . '/pj*'
    ];

    $c->stash->{ journal_number } = sub {
        my $file = shift;
        $file =~ /(\d+)/;
        return $1 ? sprintf( "%d", $1 ) : '';
    };

    $c->stash->{ figure_to_markup } = sub {
        my ( $ref, $journal ) = @_;
        return sprintf '%s%s/image_markup/%s.html', $c->req->base, $journal, $ref;
    };

    $c->stash->{ figure_link } = sub {
        my ( $ref, $journal, $size ) = @_;
        if ( $size ) {
            return sprintf 'http://www.culture.hu-berlin.de/dingler_static/%s/thumbs/%s_%s.jpg', $journal, $ref, $size;
        }
    };

    return 1;
}

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    my $journals = $c->model('Dingler::Journal')->search({}, { order_by => 'year, volume' });
    my $covers = <<"EOT";
#1-9
http://www.polytechnischesjournal.de/fileadmin/data/32258227Z/32258227Z_tif/jpegs/00000005.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258226Z/32258226Z_tif/jpegs/00000005.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258225Z/32258225Z_tif/jpegs/00000005.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30583702Z/30583702Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258224Z/32258224Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258223Z/32258223Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258222Z/32258222Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258221Z/32258221Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258220Z/32258220Z_tif/jpegs/00000007.tif.thumbnail.jpg

#10
http://www.polytechnischesjournal.de/fileadmin/data/30130090Z/30130090Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30130091Z/30130091Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258218Z/32258218Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258217Z/32258217Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258215Z/32258215Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258214Z/32258214Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258212Z/32258212Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30130092Z/30130092Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30364587Z/30364587Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422568Z/32422568Z_tif/jpegs/00000007.tif.thumbnail.jpg

#20
http://www.polytechnischesjournal.de/fileadmin/data/32422569Z/32422569Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30146146Z/30146146Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422566Z/32422566Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/31903738Z/31903738Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422567Z/32422567Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30146147Z/30146147Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422565Z/32422565Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30146148Z/30146148Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422564Z/32422564Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422563Z/32422563Z_tif/jpegs/00000007.tif.thumbnail.jpg

#30
http://www.polytechnischesjournal.de/fileadmin/data/30146149Z/30146149Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422562Z/32422562Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422561Z/32422561Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30146150Z/30146150Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30130093Z/30130093Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30130094Z/30130094Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30130095Z/30130095Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30130096Z/30130096Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422559Z/32422559Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422558Z/32422558Z_tif/jpegs/00000007.tif.thumbnail.jpg

#40
http://www.polytechnischesjournal.de/fileadmin/data/30148010Z/30148010Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148009Z/30148009Z_tif/jpegs/00000007.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148008Z/30148008Z_tif/jpegs/00000006.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258208Z/32258208Z_tif/jpegs/00000005.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258207Z/32258207Z_tif/jpegs/00000005.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148007Z/30148007Z_tif/jpegs/00000005.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148006Z/30148006Z_tif/jpegs/00000005.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258206Z/32258206Z_tif/jpegs/00000005.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258173Z/32258173Z_tif/jpegs/00000005.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258174Z/32258174Z_tif/jpegs/00000005.tif.thumbnail.jpg

#50
http://www.polytechnischesjournal.de/fileadmin/data/32258175Z/32258175Z_tif/jpegs/00000005.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258176Z/32258176Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148020Z/30148020Z_tif/jpegs/00000006.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148019Z/30148019Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258186Z/32258186Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258187Z/32258187Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258195Z/32258195Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258185Z/32258185Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258196Z/32258196Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422557Z/32422557Z_tif/jpegs/00000008.tif.thumbnail.jpg

#60
http://www.polytechnischesjournal.de/fileadmin/data/32422556Z/32422556Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422555Z/32422555Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422554Z/32422554Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422553Z/32422553Z_tif/jpegs/00000008.tif.thumbnail.jpg
#64 is missing
http://www.polytechnischesjournal.de/fileadmin/data/32422553Z/32422553Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422551Z/32422551Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148018Z/30148018Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148017Z/30148017Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422550Z/32422550Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148016Z/30148016Z_tif/jpegs/00000008.tif.thumbnail.jpg

#70
http://www.polytechnischesjournal.de/fileadmin/data/32422549Z/32422549Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422548Z/32422548Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148015Z/30148015Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148014Z/30148014Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/20203105Z/20203105Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422547Z/32422547Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422546Z/32422546Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422579Z/32422579Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422580Z/32422580Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422590Z/32422590Z_tif/jpegs/00000008.tif.thumbnail.jpg

#80
http://www.polytechnischesjournal.de/fileadmin/data/32422582Z/32422582Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422591Z/32422591Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422592Z/32422592Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148013Z/30148013Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422601Z/32422601Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422602Z/32422602Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422603Z/32422603Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422604Z/32422604Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422605Z/32422605Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422593Z/32422593Z_tif/jpegs/00000008.tif.thumbnail.jpg

#90
http://www.polytechnischesjournal.de/fileadmin/data/30148012Z/30148012Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422594Z/32422594Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422583Z/32422583Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422584Z/32422584Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148011Z/30148011Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422586Z/32422586Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422587Z/32422587Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422589Z/32422589Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422600Z/32422600Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148341Z/30148341Z_tif/jpegs/00000008.tif.thumbnail.jpg

#100
http://www.polytechnischesjournal.de/fileadmin/data/32422599Z/32422599Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422611Z/32422611Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422609Z/32422609Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422608Z/32422608Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422607Z/32422607Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148340Z/30148340Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422606Z/32422606Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422598Z/32422598Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422597Z/32422597Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422596Z/32422596Z_tif/jpegs/00000008.tif.thumbnail.jpg

#110
http://www.polytechnischesjournal.de/fileadmin/data/32422595Z/32422595Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422644Z/32422644Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422643Z/32422643Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422642Z/32422642Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422641Z/32422641Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422640Z/32422640Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422639Z/32422639Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148339Z/30148339Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422638Z/32422638Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30375080Z/30375080Z_tif/jpegs/00000008.tif.thumbnail.jpg

#120
http://www.polytechnischesjournal.de/fileadmin/data/30148338Z/30148338Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148337Z/30148337Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422636Z/32422636Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422635Z/32422635Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422634Z/32422634Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422633Z/32422633Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422632Z/32422632Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422622Z/32422622Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148347Z/30148347Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/31504784Z/31504784Z_tif/jpegs/00000008.tif.thumbnail.jpg

#130
http://www.polytechnischesjournal.de/fileadmin/data/30305580Z/30305580Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148346Z/30148346Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30130097Z/30130097Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148345Z/30148345Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148344Z/30148344Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422708Z/32422708Z_tif/jpegs/00000008.tif.thumbnail.jpg
#136 is missing
http://www.polytechnischesjournal.de/fileadmin/data/32422708Z/32422708Z_tif/jpegs/00000008.tif.thumbnail.jpg
#137 is missing
http://www.polytechnischesjournal.de/fileadmin/data/32422708Z/32422708Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422704Z/32422704Z_tif/jpegs/00000008.tif.thumbnail.jpg
#139 is missing
http://www.polytechnischesjournal.de/fileadmin/data/32422708Z/32422708Z_tif/jpegs/00000008.tif.thumbnail.jpg

#140
http://www.polytechnischesjournal.de/fileadmin/data/32422702Z/32422702Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422701Z/32422701Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422700Z/32422700Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/31070284Z/31070284Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422699Z/32422699Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422689Z/32422689Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/20210933Z/20210933Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/20335001Z/20335001Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/20335003Z/20335003Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/20335002Z/20335002Z_tif/jpegs/00000008.tif.thumbnail.jpg

#150
http://www.polytechnischesjournal.de/fileadmin/data/20335000Z/20335000Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422695Z/32422695Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422678Z/32422678Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422679Z/32422679Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422680Z/32422680Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148342Z/30148342Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422681Z/32422681Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30148343Z/30148343Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30153532Z/30153532Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422697Z/32422697Z_tif/jpegs/00000008.tif.thumbnail.jpg

#160
http://www.polytechnischesjournal.de/fileadmin/data/32199939Z/32199939Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422698Z/32422698Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422684Z/32422684Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422685Z/32422685Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422686Z/32422686Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422687Z/32422687Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30153533Z/30153533Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30153534Z/30153534Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30153535Z/30153535Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422688Z/32422688Z_tif/jpegs/00000008.tif.thumbnail.jpg

#170
http://www.polytechnischesjournal.de/fileadmin/data/32422743Z/32422743Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422742Z/32422742Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422741Z/32422741Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422740Z/32422740Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30130098Z/30130098Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422739Z/32422739Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422738Z/32422738Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30153536Z/30153536Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30153542Z/30153542Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422737Z/32422737Z_tif/jpegs/00000008.tif.thumbnail.jpg

#180
http://www.polytechnischesjournal.de/fileadmin/data/30153541Z/30153541Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30153540Z/30153540Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30153539Z/30153539Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30153538Z/30153538Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422736Z/32422736Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/30153537Z/30153537Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422735Z/32422735Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422734Z/32422734Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422732Z/32422732Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422731Z/32422731Z_tif/jpegs/00000008.tif.thumbnail.jpg

#190
http://www.polytechnischesjournal.de/fileadmin/data/32422730Z/32422730Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32213059Z/32213059Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32213036Z/32213036Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32213047Z/32213047Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32213058Z/32213058Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32213035Z/32213035Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32213046Z/32213046Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32213057Z/32213057Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32258052Z/32258052Z_tif/jpegs/00000008.tif.thumbnail.jpg
#199 is missing
http://www.polytechnischesjournal.de/fileadmin/data/32258052Z/32258052Z_tif/jpegs/00000008.tif.thumbnail.jpg

#200
http://www.polytechnischesjournal.de/fileadmin/data/32422624Z/32422624Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422613Z/32422613Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422614Z/32422614Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422615Z/32422615Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422616Z/32422616Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422617Z/32422617Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422618Z/32422618Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422619Z/32422619Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422620Z/32422620Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422621Z/32422621Z_tif/jpegs/00000008.tif.thumbnail.jpg

#210
http://www.polytechnischesjournal.de/fileadmin/data/32422630Z/32422630Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422625Z/32422625Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422626Z/32422626Z_tif/jpegs/00000009.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422627Z/32422627Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422628Z/32422628Z_tif/jpegs/00000012.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422629Z/32422629Z_tif/jpegs/00000008.tif.thumbnail.jpg
#216 is missing
http://www.polytechnischesjournal.de/fileadmin/data/32422629Z/32422629Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422726Z/32422726Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422725Z/32422725Z_tif/jpegs/00000008.tif.thumbnail.jpg
#219 is missing
http://www.polytechnischesjournal.de/fileadmin/data/32422725Z/32422725Z_tif/jpegs/00000008.tif.thumbnail.jpg

#220
#220 is missing
http://www.polytechnischesjournal.de/fileadmin/data/32422721Z/32422721Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422721Z/32422721Z_tif/jpegs/00000008.tif.thumbnail.jpg
http://www.polytechnischesjournal.de/fileadmin/data/32422711Z/32422711Z_tif/jpegs/00000008.tif.thumbnail.jpg
EOT

    my @covers = grep { !/^$/ }grep { !/^#/ } split /\n/, $covers;

    $c->stash(
        covers      => \@covers,
        journals    => $journals,
        template    => 'start.tt',
    );
    $c->forward('stats');
}

=head2 stats

=cut

sub stats :Private {
    my ( $self, $c ) = @_;

    my $cache = Cache::FileCache->new({
        cache_root => $c->path_to( 'var', 'cache' )."",
        namespace  => 'dingler-stats'
    });

    my $stats = $cache->get('stats');
    if ( not defined $stats ) {
        my $articles    = $c->model('Dingler::Article')->search({ type => 'art_undef' })->count;
        my $patentdescs = $c->model('Dingler::Article')->search({ type => 'art_patent' })->count;
        my $patentlists = $c->model('Dingler::Article')->search({ -or => [ type => ['art_patents', 'misc_patents'] ] })->count;
        my $miscs       = $c->model('Dingler::Article')->search({ type => 'misc_undef' })->count;
        my $tables      = $c->model('Dingler::Figure')->search({ reftype => 'tabular' }, { group_by => ['ref'] } )->count;
        my $patents     = $c->model('Dingler::Patent')->search->count;

        # count persons
        my $xml = XML::LibXML->new->parse_file( $c->config->{svn} . '/database/persons/persons.xml' );
        my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
        $xpc->registerNs( 'tei', 'http://www.tei-c.org/ns/1.0' );
        my $persons = $xpc->findnodes('//tei:person')->size;

        # count sources
        $xml = XML::LibXML->new->parse_file( $c->config->{svn} . '/database/journals/journals.xml' );
        $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
        $xpc->registerNs( 'tei', 'http://www.tei-c.org/ns/1.0' );
        my $sources = $xpc->findnodes('//tei:bibl')->size;

        # count characters
        my $chars = $c->model('Dingler::Article')->search( undef, {
            'select' => [ { sum => \'LENGTH(content) + LENGTH(front)' } ],
            as       => 'chars',
        } )->first->get_column('chars');

        # count figures
        my $figures = 0;
      IMAGE_MARKUP:
        foreach my $imt ( glob $c->config->{svn} . '/*/image_markup/*.xml' ) {
            eval { $xml = XML::LibXML->new->parse_file( $imt ); 1 };
            next IMAGE_MARKUP if $@;
            $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
            $xpc->registerNs( 'tei', 'http://www.tei-c.org/ns/1.0' );
            $figures += $xpc->findnodes('/tei:TEI/tei:text/tei:body/tei:div/tei:div')->size;
        }

        $cache->set( articles    => $articles );
        $cache->set( patentdescs => $patentdescs );
        $cache->set( patentlists => $patentlists );
        $cache->set( miscs       => $miscs );
        $cache->set( chars       => $chars );
        $cache->set( tables      => $tables );
        $cache->set( figures     => $figures );
        $cache->set( persons     => $persons );
        $cache->set( sources     => $sources );
        $cache->set( patents     => $patents );
        $cache->set( stats       => 1 );
    }

    $c->stash(
        articles    => $cache->get('articles'),
        patentdescs => $cache->get('patentdescs'),
        patentlists => $cache->get('patentlists'),
        miscs       => $cache->get('miscs'),
        chars       => $cache->get('chars'),
        tables      => $cache->get('tables'),
        figures     => $cache->get('figures'),
        persons     => $cache->get('persons'),
        sources     => $cache->get('sources'),
        patents     => $cache->get('patents'),
    );
    my $favcookie = $c->req->cookie('dinglerfav');
    if ( $favcookie ) {
        $c->stash->{favs} = $c->model('Fav::Cookie')->search({ uniqid  => $favcookie->value })->count;
    }
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->stash(
        template => 'http/404.tt',
    );
    $c->response->status(404);
}

=head2 end

=cut

sub end :Private {
    my ($self, $c) = @_;
    return 1 if $c->response->status =~ /^(?:3\d\d)|(?:204)$/;
    return 1 if $c->response->body || $c->stash->{_output};

    if ( !defined $c->res->output || (!$c->res->output && $c->res->output ne '0') ) {
        my $view = $c->stash->{view} || 'TT';
        $c->forward( $c->view($view) );
        $c->fillform( $c->stash->{form} ) if $c->stash->{form};
    }

    # custom 500 page
    if ( my @errors = @{$c->error} ) {
        foreach my $error (@errors) {
            $c->log->error( $error );
        }
        $c->clear_errors;
        $c->stash(
            template => 'http/500.tt',
            errors   => \@errors,
        );
        $c->response->status(500);
        $c->forward( $c->view('TT') );
    }
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 AUTHOR

Frank Wiegand

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
