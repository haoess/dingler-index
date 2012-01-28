use utf8;
package Dingler::Schema::Result::Patent;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dingler::Schema::Result::Patent

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<patent>

=cut

__PACKAGE__->table("patent");

=head1 ACCESSORS

=head2 id

  data_type: 'text'
  is_nullable: 0

=head2 article

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 subtype

  data_type: 'text'
  is_nullable: 1

=head2 date

  data_type: 'date'
  is_nullable: 1

=head2 xml

  data_type: 'text'
  is_nullable: 1

=head2 content

  data_type: 'text'
  is_nullable: 1

=head2 title

  data_type: 'text'
  is_nullable: 1

=head2 place

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "text", is_nullable => 0 },
  "article",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "subtype",
  { data_type => "text", is_nullable => 1 },
  "date",
  { data_type => "date", is_nullable => 1 },
  "xml",
  { data_type => "text", is_nullable => 1 },
  "content",
  { data_type => "text", is_nullable => 1 },
  "title",
  { data_type => "text", is_nullable => 1 },
  "place",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 article

Type: belongs_to

Related object: L<Dingler::Schema::Result::Article>

=cut

__PACKAGE__->belongs_to(
  "article",
  "Dingler::Schema::Result::Article",
  { uid => "article" },
  { join_type => "LEFT" },
);

=head2 patent_apps

Type: has_many

Related object: L<Dingler::Schema::Result::PatentApp>

=cut

__PACKAGE__->has_many(
  "patent_apps",
  "Dingler::Schema::Result::PatentApp",
  { "foreign.patent" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2012-01-25 13:04:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Fq+Kh1YIpWgAdK9wNmJxdQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
