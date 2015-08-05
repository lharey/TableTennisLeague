use utf8;
package Schema::Result::League;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::League

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<league>

=cut

__PACKAGE__->table("league");

=head1 ACCESSORS

=head2 player

  data_type: 'text'
  is_nullable: 0

=head2 score

  data_type: 'int'
  default_value: 0
  is_nullable: 0

=head2 played

  data_type: 'int'
  default_value: 0
  is_nullable: 0

=head2 won

  data_type: 'int'
  default_value: 0
  is_nullable: 0

=head2 drawn

  data_type: 'int'
  default_value: 0
  is_nullable: 0

=head2 lost

  data_type: 'int'
  default_value: 0
  is_nullable: 0

=head2 for

  data_type: 'int'
  default_value: 0
  is_nullable: 0

=head2 against

  data_type: 'int'
  default_value: 0
  is_nullable: 0

=head2 points_diff

  data_type: 'int'
  default_value: 0
  is_nullable: 0

=head2 season_number

  data_type: 'int'
  default_value: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "player",
  { data_type => "text", is_nullable => 0 },
  "score",
  { data_type => "int", default_value => 0, is_nullable => 0 },
  "played",
  { data_type => "int", default_value => 0, is_nullable => 0 },
  "won",
  { data_type => "int", default_value => 0, is_nullable => 0 },
  "drawn",
  { data_type => "int", default_value => 0, is_nullable => 0 },
  "lost",
  { data_type => "int", default_value => 0, is_nullable => 0 },
  "for",
  { data_type => "int", default_value => 0, is_nullable => 0 },
  "against",
  { data_type => "int", default_value => 0, is_nullable => 0 },
  "points_diff",
  { data_type => "int", default_value => 0, is_nullable => 0 },
  "season_number",
  { data_type => "int", default_value => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</player>

=back

=cut

__PACKAGE__->set_primary_key("player");

=head1 RELATIONS

=head2 rounds_player1s

Type: has_many

Related object: L<Schema::Result::Round>

=cut

__PACKAGE__->has_many(
  "rounds_player1s",
  "Schema::Result::Round",
  { "foreign.player1" => "self.player" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 rounds_player2s

Type: has_many

Related object: L<Schema::Result::Round>

=cut

__PACKAGE__->has_many(
  "rounds_player2s",
  "Schema::Result::Round",
  { "foreign.player2" => "self.player" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2015-07-28 09:20:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1oMVQVD8cviTnrQbsrEWUw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
