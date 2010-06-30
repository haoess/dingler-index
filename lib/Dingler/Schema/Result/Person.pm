package Dingler::Schema::Result::Person;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Dingler::Schema::Result::Person

=cut

__PACKAGE__->table("person");

=head1 ACCESSORS

=head2 id

  data_type: text
  default_value: undef
  is_nullable: 0

=head2 ref

  data_type: text
  default_value: undef
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "text", default_value => undef, is_nullable => 0 },
  "ref",
  { data_type => "text", default_value => undef, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id", "ref");


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2010-06-30 15:15:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Q4E+n6ih2FMfcSwpQYFOHg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
