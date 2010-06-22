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

=head2 id

  data_type: integer
  default_value: nextval('figure_id_seq'::regclass)
  is_auto_increment: 1
  is_nullable: 0

=head2 article

  data_type: text
  default_value: undef
  is_foreign_key: 1
  is_nullable: 1

=head2 url

  data_type: text
  default_value: undef
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    default_value     => \"nextval('figure_id_seq'::regclass)",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "article",
  {
    data_type      => "text",
    default_value  => undef,
    is_foreign_key => 1,
    is_nullable    => 1,
  },
  "url",
  { data_type => "text", default_value => undef, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 article

Type: belongs_to

Related object: L<Dingler::Schema::Result::Article>

=cut

__PACKAGE__->belongs_to(
  "article",
  "Dingler::Schema::Result::Article",
  { id => "article" },
  { join_type => "LEFT" },
);


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2010-06-22 12:02:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ANMi7LbGeKj/CPrpO3KXJg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
