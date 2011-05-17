package Dingler;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    ConfigLoader
    Authentication

    Session::DynamicExpiry
    Session
    Session::Store::File
    Session::State::Cookie

    AccessLog
    Static::Simple
    Unicode::Encoding
/;

extends 'Catalyst';

our $VERSION = '0.01';
$VERSION = eval $VERSION;

# Configure the application.
#
# Note that settings in dingler.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

open( LOGFH, '>>', __PACKAGE__->path_to( 'var', 'logfile' )->stringify ) or die $!;
binmode( LOGFH, ":unix" );

__PACKAGE__->config(
    name => 'Dingler',
    encoding => 'UTF-8',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    'Plugin::AccessLog' => {
        target => \*LOGFH,
        formatter => {
            time_format => '%c',
            time_zone => 'Europe/Berlin',
        },
    },
    'Plugin::Authentication' => {
        default_realm => 'admins',
        realms => {
            admins => {
                credential => {
                    class              => 'Password',
                    password_field     => 'passwd',
                    password_type      => 'hashed',
                    password_hash_type => 'SHA-1',
                },
                store => {
                    class      => 'DBIx::Class',
                    user_class => 'DinglerWeb::Admin',
                    id_field   => 'id',
                },
            },
        },
    },
    static => {
        include_path => [
            __PACKAGE__->config->{root},
            \&incpath_generator,
        ],
        ignore_extensions => [ qw(tt xslt) ],
#        debug => 1,
#        logging => 1,
    },
);

sub incpath_generator {
    my $c = shift;
    return [
        $c->config->{svn},
        __PACKAGE__->path_to( 'var', 'timeline-search' )."",
    ];
}

# Start the application
__PACKAGE__->setup();

1;
__END__

=head1 NAME

Dingler - Catalyst based application

=head1 SYNOPSIS

    script/dingler_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Dingler::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Frank Wiegand

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
