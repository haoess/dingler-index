package Dingler::Schema::Result::Gnd;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Dingler::Schema::Result::Gnd

=cut

__PACKAGE__->table("gnd");

=head1 ACCESSORS

=head2 id

  data_type: integer
  default_value: nextval('gnd_id_seq'::regclass)
  is_auto_increment: 1
  is_nullable: 0

=head2 subject

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 predicate

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 object

  data_type: text
  default_value: undef
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    default_value     => \"nextval('gnd_id_seq'::regclass)",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "subject",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "predicate",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "object",
  { data_type => "text", default_value => undef, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2011-02-15 20:04:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/MZR4BN0+7tPh7Q8lpuAXQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
