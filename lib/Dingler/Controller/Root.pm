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
        my $str = shift;
        # http://www.culture.hu-berlin.de/dingler_static/pj044/image_markup/tab044493_wv_tab044493.jpg
        #   =>
        # /pj044/image_markup/tab044493.html
        $str =~ s{.*/(pj\d{3}/image_markup/\w+)_wv_.*\z}{@{[ $c->req->base ]}$1.html};
        return $str;
    };

    return 1;
}

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    my $journals = $c->model('Dingler::Journal')->search({}, { order_by => 'year, volume' });
    my $articles = $c->model('Dingler::Article')->search;
    my $figures  = $c->model('Dingler::Figure')->search,
    my $persons  = $c->model('Dingler::Person')->search,

    my $cache = Cache::FileCache->new({
        cache_root => $c->path_to( 'var', 'cache' )."",
        namespace  => 'dingler-stats'
    });
    my $chars = $cache->get( 'total_chars' );
    if ( not defined $chars ) {
        $chars    = $c->model('Dingler::Article')->search( undef, {
            'select' => [ { sum => \'LENGTH(content) + LENGTH(front)' } ],
            as       => 'chars',
        } )->first->get_column('chars');
        $cache->set( 'total_chars', $chars );
    }
    $c->stash(
        journals => $journals,
        articles => $articles,
        chars    => $chars,
        figures  => $figures,
        persons  => $persons,
        template => 'start.tt',
    );
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
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
