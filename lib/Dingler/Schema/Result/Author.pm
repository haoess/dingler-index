package Dingler::Schema::Result::Author;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Dingler::Schema::Result::Author

=cut

__PACKAGE__->table("author");

=head1 ACCESSORS

=head2 person

  data_type: text
  default_value: undef
  is_nullable: 0

=head2 article

  data_type: text
  default_value: undef
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "person",
  { data_type => "text", default_value => undef, is_nullable => 0 },
  "article",
  {
    data_type      => "text",
    default_value  => undef,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);
__PACKAGE__->set_primary_key("person", "article");

=head1 RELATIONS

=head2 article

Type: belongs_to

Related object: L<Dingler::Schema::Result::Article>

=cut

__PACKAGE__->belongs_to(
  "article",
  "Dingler::Schema::Result::Article",
  { id => "article" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2010-06-30 15:15:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PN/Dxs36OzDN62Rg9MYKbw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
