use utf8;
package Dingler::Schema::Result::Article;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dingler::Schema::Result::Article

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

=head1 TABLE: C<article>

=cut

__PACKAGE__->table("article");

=head1 ACCESSORS

=head2 uid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'article_uid_seq'

=head2 id

  data_type: 'text'
  is_nullable: 1

=head2 parent

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 journal

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=head2 type

  data_type: 'text'
  is_nullable: 1

=head2 subtype

  data_type: 'text'
  is_nullable: 1

=head2 volume

  data_type: 'text'
  is_nullable: 1

=head2 number

  data_type: 'text'
  is_nullable: 1

=head2 title

  data_type: 'text'
  is_nullable: 1

=head2 pagestart

  data_type: 'text'
  is_nullable: 1

=head2 pageend

  data_type: 'text'
  is_nullable: 1

=head2 facsimile

  data_type: 'text'
  is_nullable: 1

=head2 front

  data_type: 'text'
  is_nullable: 1

=head2 content

  data_type: 'text'
  is_nullable: 1

=head2 position

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "uid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "article_uid_seq",
  },
  "id",
  { data_type => "text", is_nullable => 1 },
  "parent",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "journal",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
  "type",
  { data_type => "text", is_nullable => 1 },
  "subtype",
  { data_type => "text", is_nullable => 1 },
  "volume",
  { data_type => "text", is_nullable => 1 },
  "number",
  { data_type => "text", is_nullable => 1 },
  "title",
  { data_type => "text", is_nullable => 1 },
  "pagestart",
  { data_type => "text", is_nullable => 1 },
  "pageend",
  { data_type => "text", is_nullable => 1 },
  "facsimile",
  { data_type => "text", is_nullable => 1 },
  "front",
  { data_type => "text", is_nullable => 1 },
  "content",
  { data_type => "text", is_nullable => 1 },
  "position",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</uid>

=back

=cut

__PACKAGE__->set_primary_key("uid");

=head1 RELATIONS

=head2 articles

Type: has_many

Related object: L<Dingler::Schema::Result::Article>

=cut

__PACKAGE__->has_many(
  "articles",
  "Dingler::Schema::Result::Article",
  { "foreign.parent" => "self.uid" },
  {},
);

=head2 figures

Type: has_many

Related object: L<Dingler::Schema::Result::Figure>

=cut

__PACKAGE__->has_many(
  "figures",
  "Dingler::Schema::Result::Figure",
  { "foreign.article" => "self.uid" },
  {},
);

=head2 footnotes

Type: has_many

Related object: L<Dingler::Schema::Result::Footnote>

=cut

__PACKAGE__->has_many(
  "footnotes",
  "Dingler::Schema::Result::Footnote",
  { "foreign.article" => "self.uid" },
  {},
);

=head2 journal

Type: belongs_to

Related object: L<Dingler::Schema::Result::Journal>

=cut

__PACKAGE__->belongs_to(
  "journal",
  "Dingler::Schema::Result::Journal",
  { id => "journal" },
  { join_type => "LEFT" },
);

=head2 parent

Type: belongs_to

Related object: L<Dingler::Schema::Result::Article>

=cut

__PACKAGE__->belongs_to(
  "parent",
  "Dingler::Schema::Result::Article",
  { uid => "parent" },
  { join_type => "LEFT" },
);

=head2 patents

Type: has_many

Related object: L<Dingler::Schema::Result::Patent>

=cut

__PACKAGE__->has_many(
  "patents",
  "Dingler::Schema::Result::Patent",
  { "foreign.article" => "self.uid" },
  {},
);

=head2 personrefs

Type: has_many

Related object: L<Dingler::Schema::Result::Personref>

=cut

__PACKAGE__->has_many(
  "personrefs",
  "Dingler::Schema::Result::Personref",
  { "foreign.ref" => "self.uid" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2012-01-25 13:04:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:APcUTVwJWR81NC9Z4O8lkQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
