package Dingler::Controller::Fav;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use DateTime;
use Digest::SHA qw(sha1_hex);

=head1 NAME

Dingler::Controller::Fav - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 list

=cut

sub list :Local {
    my ( $self, $c ) = @_;
    my $favcookie = $c->req->cookie('dinglerfav');
    if ( $favcookie ) {
        my @favs = map {
                       $_->{article} = $c->model('Dingler::Article')->find( $_->article );
                       $_;
                   }
                   $c->model('Fav::Cookie')->search(
                       { uniqid   => $favcookie->value },
                       { order_by => 'created DESC' }
                   )->all;
        $c->stash( favs => \@favs );
    }
}

=head2 add

=cut

sub add :Local {
    my ( $self, $c, $article ) = @_;

    my $uniqid;
    my $favcookie = $c->req->cookie('dinglerfav');
    if ( !$favcookie ) {
        $uniqid = sha1_hex( time, rand, $$ );
        $c->res->cookies->{dinglerfav} = {
            expires => '+3y',
            value   => $uniqid,
        };
    }
    else {
        $uniqid = $favcookie->value;
    }

    $c->model('Fav::Cookie')->find_or_create({
        article => $article,
        uniqid  => $uniqid,
        created => DateTime->now,
    });
    $c->res->body('');
}

=head2 delete

=cut

sub delete :Local {
    my ( $self, $c, $article ) = @_;
    my $favcookie = $c->req->cookie('dinglerfav');
    if ( $favcookie ) {
        $c->model('Fav::Cookie')->search({
            article => $article,
            uniqid  => $favcookie->value,
        })->delete;
    }
    $c->res->body('');
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
