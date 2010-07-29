package Dingler::Schema::Result::Cookie;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Dingler::Schema::Result::Cookie

=cut

__PACKAGE__->table("cookie");

=head1 ACCESSORS

=head2 id

  data_type: INTEGER
  default_value: undef
  is_nullable: 1
  size: undef

=head2 article

  data_type: TEXT
  default_value: undef
  is_nullable: 1
  size: undef

=head2 uniqid

  data_type: TEXT
  default_value: undef
  is_nullable: 1
  size: undef

=head2 created

  data_type: DATETIME
  default_value: undef
  is_nullable: 1
  size: undef

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "article",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "uniqid",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "created",
  {
    data_type => "DATETIME",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2010-07-29 23:52:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rP5FIDLLuS1RY7dgNoYBdQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
