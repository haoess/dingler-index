package Dingler::Schema::Result::Personref;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Dingler::Schema::Result::Personref

=cut

__PACKAGE__->table("personref");

=head1 ACCESSORS

=head2 id

  data_type: text
  default_value: undef
  is_foreign_key: 1
  is_nullable: 0

=head2 ref

  data_type: integer
  default_value: undef
  is_foreign_key: 1
  is_nullable: 0

=head2 role

  data_type: text
  default_value: undef
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type      => "text",
    default_value  => undef,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "ref",
  {
    data_type      => "integer",
    default_value  => undef,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "role",
  { data_type => "text", default_value => undef, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id", "ref", "role");

=head1 RELATIONS

=head2 id

Type: belongs_to

Related object: L<Dingler::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to("id", "Dingler::Schema::Result::Person", { id => "id" }, {});

=head2 ref

Type: belongs_to

Related object: L<Dingler::Schema::Result::Article>

=cut

__PACKAGE__->belongs_to("ref", "Dingler::Schema::Result::Article", { uid => "ref" }, {});


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2010-11-11 22:29:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VSp+v9kvrmkyIG2Oqd4txw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
