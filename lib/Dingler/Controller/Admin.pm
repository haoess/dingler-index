package Dingler::Controller::Admin;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Dingler::Controller::Admin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 auto

=cut

sub auto : Private {
    my ( $self, $c ) = @_;
    return 1;
}

=head2 index

=cut

sub index : Private {
    my ( $self, $c ) = @_;
    if ( !$c->user_in_realm('admins') ) {
        $c->detach( '/admin/login' );
        return 0;
    }
}

=head2 login

=cut

sub login : Local {
    my ( $self, $c ) = @_;
    $c->stash(
        template => 'admin/login.tt',
    );
}

=head2 do_login

=cut

sub do_login : Local {
    my ( $self, $c ) = @_;

    my $username = $c->req->param('username');
    my $password = $c->req->param('password');
    my $auth = $c->authenticate({
        passwd => $password,
        dbix_class => {
            searchargs => [{
                -or => [
                    username => $username,
                    email    => $username,
                ],
            }],
        },
    });
    if ($auth) {
        $c->session_time_to_live( 60 * 60 * 24 * 7 );
        $c->user->update({ lastlogin => DateTime->now });
        $c->res->redirect( $c->uri_for('/admin') );
    }
    else {
        $c->stash(
            template => 'admin/auth_failed.tt',
        );
    }
}

=head2 logout

=cut

sub logout : Local {
    my ($self, $c) = @_;
    $c->logout;
    $c->res->redirect( $c->uri_for('/') );
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
