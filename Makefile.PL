#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'Dingler';
all_from 'lib/Dingler.pm';

requires 'Catalyst::Runtime' => '5.80024';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Moose';
requires 'namespace::autoclean';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
requires 'Catalyst::View::XSLT';
requires 'Catalyst::TraitFor::Request::ProxyBase';
requires 'HTML::TagCloud';
requires 'Catalyst::Plugin::Unicode::Encoding';
requires 'XML::Simple';
requires 'XML::LibXML' => '1.70';
requires 'XML::LibXSLT' => '1.70';
requires 'Text::BibTeX';
requires 'Cache::FileCache';
requires 'List::MoreUtils';
requires 'DateTime';
requires 'DBIx::Class::Schema';
requires 'Catalyst::Model::DBIC::Schema';
requires 'DateTime::Format::SQLite';
requires 'File::Temp';
requires 'DBD::Pg';
requires 'Data::Page';
requires 'Catalyst::Plugin::AccessLog';
requires 'XML::Feed';
requires 'Digest::SHA';
requires 'DateTime::Format::Pg';
requires 'Roman';
requires 'YAML::XS';
requires 'Text::Wrap';
requires 'MIME::Lite';
test_requires 'Test::More' => '0.88';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
