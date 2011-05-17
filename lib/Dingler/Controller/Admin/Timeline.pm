package Dingler::Controller::Admin::Timeline;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use XML::Simple;

=head1 NAME

Dingler::Controller::Admin::Timeline - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 auto

=cut

sub auto : Private {
    my ( $self, $c ) = @_;
    if ( !$c->user_in_realm('admins') ) {
        $c->detach( '/admin/login' );
        return 0;
    }
    return 1;
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(
        events => [ $c->model('DinglerWeb::Event')->search( undef, {
            prefetch => [ { event_categories => 'category' } ],
            order_by => 'startyear, startmonth, startday',
        }) ],
        template => 'admin/timeline/index.tt',
    );
}

=head2 create

=cut

sub create : Local {
    my ( $self, $c ) = @_;
    my ( $sy, $sm, $sd ) = split /-/, $c->req->params->{start};
    my ( $ey, $em, $ed ) = split /-/, $c->req->params->{end};
    my $event = $c->model('DinglerWeb::Event')->create({
        title       => $c->req->params->{title},
        description => $c->req->params->{description},
        image       => $c->req->params->{image},
        link        => $c->req->params->{link},
        startyear   => $sy,
        startmonth  => $sm,
        startday    => $sd,
        endyear     => $ey,
        endmonth    => $em,
        endday      => $ed,
    });
    my @tags = split /\s*;\s*/, $c->req->params->{categories};
    foreach my $tag ( @tags ) {
        my $category = $c->model('DinglerWeb::Category')->find_or_create({
            name => $tag,
        });
        $c->model('DinglerWeb::EventCategory')->create({
            event    => $event->id,
            category => $category->id,
        });
    }
    $c->res->redirect( $c->uri_for('/admin/timeline') );
}

=head2 upload

=cut

sub upload : Local {
    my ( $self, $c ) = @_;
    my $file = $c->req->upload('file');
    $c->detach('index') unless $file;

    my $xml = XMLin( $file->fh )->{event};
    my @tags = split /\s*;\s*/, $c->req->params->{tags};

    foreach my $entry ( @$xml ) {
        no warnings 'uninitialized';
        my ( $sy, $sm, $sd ) = split /-/, $entry->{start};
        my ( $ey, $em, $ed ) = split /-/, $entry->{end};
        my $event = $c->model('DinglerWeb::Event')->create({
            title       => $entry->{title},
            startyear   => $sy,
            startmonth  => $sm,
            startday    => $sd,
            endyear     => $ey,
            endmonth    => $em,
            endday      => $ed,
            link        => $entry->{link},
            image       => $entry->{image},
            description => $entry->{content},
        });
        foreach my $tag ( @tags ) {
            my $category = $c->model('DinglerWeb::Category')->find_or_create({
                name => $tag,
            });
            $c->model('DinglerWeb::EventCategory')->create({
                event    => $event->id,
                category => $category->id,
            });
        }
    }
    $c->res->redirect( $c->uri_for('/admin/timeline') );
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
