package Dingler::Index;
use Moose;

use utf8;

use Memoize;
memoize('grundform');

has 'text' => (
    isa => 'Str',
    is  => 'rw',
);

my %stop = map { utf8::encode $_; chomp; $_ => 1 } <DATA>;

sub words {
    my $self = shift;
    my $text = $self->text;
    utf8::decode($text);
    for ( $text ) {
        s/\s+/ /;
    }
    my %words;
    foreach my $word ( split /[\s,.=–:\d();?×<>\/]+/, $text ) {
        next if $stop{lc $word};
        next unless $word =~ /\A[A-Z]/;
        next if length $word < 3;
        for ( $word ) {
            s/\AAe/Ä/;
            s/\AOe/Ö/;
            s/\AUe/Ü/;
        }
        my $gf = grundform( $word );
        $words{$word}++;
    }
    return \%words;
}

sub grundform {
    my $word = shift;
    return $word;
}

__PACKAGE__->meta->make_immutable;

1;
__DATA__
aber
als
also
am
auch
auf
aus
bei
bis
das
daß
dem
den
der
des
die
diese
dieser
dieses
durch
ein
eine
einem
einen
einer
eines
er
es
etwas
fig
für
gegen
hat
hrn
hier
ich
in
indem
irgend
ist
jeder
kann
man
mehr
mit
nach
nicht
noch
nun
nur
oder
sein
seine
seiner
sehr
sich
sie
so
über
um
und
von
wenn
werden
welche
welcher
welches
wie
wird
wodurch
zu
zum
