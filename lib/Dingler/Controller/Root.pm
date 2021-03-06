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

    my $base = $c->req->base;
    $c->stash->{ figure_to_markup } = sub {
        my $ref = shift;
        my ( $journal ) = $ref =~ /[a-z]+(\d{3}a?)/;
        return sprintf '%spj%s/image_markup/%s.html', $base, $journal, $ref;
    };

    $c->stash->{ figure_link } = sub {
        my ( $ref, $size ) = @_;
        my ( $journal ) = $ref =~ /^[a-z]+(\d{3}a?)/;
        if ( $size ) {
            return sprintf 'http://dingler.culture.hu-berlin.de/dingler_static/pj%s/thumbs/%s_%s.jpg', $journal, $ref, $size;
        }
        else {
            my $barcode = $c->model('Dingler::Journal')->find( "pj$journal" )->barcode;
            return sprintf 'http://dingler.culture.hu-berlin.de/dingler_static/pj%s/%s/%s.png', $journal, $barcode, $ref;
        }
    };

    return 1;
}

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    my $journals = $c->model('Dingler::Journal')->search({}, { order_by => 'id' });
    my $covers = <<"EOT";
#1-9
05
05
05
07
07
07
07
07
07

#10
07
07
07
07
07
07
07
07
07
07

#20
07
07
07
07
07
07
07
07
07
07

#30
07
07
07
07
07
07
07
07
07
07

#40
07
07
06
05
05
05
05
05
05
05

#50
05
08
06
08
08
08
08
08
08
08

#60
08
08
08
08
#64 is missing
08
08
08
08
08
08

#70
08
08
08
08
08
08
08
08
08
08

#80
08
08
08
08
08
08
08
08
08
08

#90
08
08
08
08
08
08
08
08
08
08

#100
08
08
08
08
08
08
08
08
08
08

#110
08
08
08
08
08
08
08
08
08
08

#120
08
08
08
08
08
08
08
08
08
08

#130
08
08
08
08
08
08
#136 is missing
08
#137 is missing
08
08
#139 is missing
08

#140
08
08
08
08
08
08
08
08
08
08

#150
08
08
08
08
08
08
08
08
08
08

#160
08
08
08
08
08
08
08
08
08
08

#170
08
08
08
08
08
08
08
08
08
08

#180
08
08
08
08
08
08
08
08
08
08

#190
08
08
08
08
08
08
08
08
08
#199 is missing
08

#200
08
08
08
08
08
08
08
08
08
08

#210
08
08
09
08
12
08
#216 is missing
08
08
08
#219 is missing
08

#220
#220 is missing
08
08
08
08
EOT

    my @covers = map { int $_ } grep { !/^$/ }grep { !/^#/ } split /\n/, $covers;

    $c->stash(
        covers      => \@covers,
        journals    => $journals,
        template    => 'start.tt',
    );
    $c->forward('stats');
}

=head2 brokenlinks

Somewhere our links to articles are broken, this action tries to redirect
our customers.

=cut

sub brokenlinks :Regex('^((?:ar|mi)([0-9]{3}).*)') {
    my ( $self, $c ) = @_;
    my $article = $c->req->captures->[0];
    my $journal = $c->req->captures->[1];
    # 301: Moved permanently
    $c->res->redirect( $c->uri_for("/article/pj$journal/$article"), 301 );
}

sub terms :Global {}

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
        $c->res->content_type( 'text/html' );
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
