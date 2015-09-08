use utf8;
package Schema::Result::Signup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::Signup

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

=head1 TABLE: C<signup>

=cut

__PACKAGE__->table("signup");

=head1 ACCESSORS

=head2 player

  data_type: 'text'
  is_nullable: 0

=head2 email

  data_type: 'text'
  is_nullable: 0

=head2 season_number

  data_type: 'int'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "player",
  { data_type => "text", is_nullable => 0 },
  "email",
  { data_type => "text", is_nullable => 0 },
  "season_number",
  { data_type => "int", is_nullable => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2015-07-28 09:20:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:g75NKqU1fHMw6OG6eCnMIw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
