package Dingler::Index;
use Moose;

use locale;
use utf8;

has 'text' => (
    isa => 'Str',
    is  => 'rw',
);

my @stop = qw(
    aber
    als
    am
    auch
    auf
    aus
    bei
    das
    daß
    dem
    den
    der
    des
    die
    ein
    eine
    einem
    einen
    eines
    er
    es
    fig
    hat
    hrn
    ich
    in
    ist
    kann
    man
    mehr
    mit
    nach
    nicht
    sehr
    sich
    so
    um
    und
    von
    wenn
    werden
    welcher
    wird
    zu
    zum
);
my %stop = map { $_ => 1 } @stop;

sub words {
    my $self = shift;
    for ( $self->text ) {
        s/\s+/ /;
    }
    my %words;
    foreach my $word ( split /[\s,.=–:\d();?×<>\/]+/, $self->text ) {
        next if $stop{lc $word};
        next unless $word =~ /\A[A-Z]/;
        next if length $word < 3;
        $words{$word}++;
    }
    return \%words;
}

1;
