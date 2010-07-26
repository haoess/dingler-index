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
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "text", default_value => undef, is_nullable => 0 },
  "ref",
  {
    data_type      => "text",
    default_value  => undef,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);
__PACKAGE__->set_primary_key("id", "ref");

=head1 RELATIONS

=head2 ref

Type: belongs_to

Related object: L<Dingler::Schema::Result::Article>

=cut

__PACKAGE__->belongs_to("ref", "Dingler::Schema::Result::Article", { id => "ref" }, {});


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2010-07-26 22:28:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5rj/R380P3AWn+DPzH+egA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
