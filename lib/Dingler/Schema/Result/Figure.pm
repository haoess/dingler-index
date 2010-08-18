package Dingler::Schema::Result::Figure;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Dingler::Schema::Result::Figure

=cut

__PACKAGE__->table("figure");

=head1 ACCESSORS

=head2 article

  data_type: text
  default_value: undef
  is_foreign_key: 1
  is_nullable: 0

=head2 ref

  data_type: text
  default_value: undef
  is_nullable: 0

=head2 reftype

  data_type: text
  default_value: undef
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "article",
  {
    data_type      => "text",
    default_value  => undef,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "ref",
  { data_type => "text", default_value => undef, is_nullable => 0 },
  "reftype",
  { data_type => "text", default_value => undef, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("article", "ref");

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


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2010-08-18 17:55:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8hSKXWNGDN9fxHSh6Y+0QQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
