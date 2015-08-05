=head1 NAME

TableTennisLeague::Utils

=head1 DESCRIPTION

Handles common utilities

=head1 AUTHOR

Lisa Hare

=head1 METHODS

=over

=cut

package TableTennisLeague::Utils;

use 5.010;
use strict;
use warnings;
use Games::Tournament::RoundRobin;

use Moo;

has season => (
    is       => 'ro',
    required => 1
);

sub create_new_season {
    my ($self) = @_;

    # Create new season
    my @signup = TableTennisLeague->model('DB::Signup')->search({
        season_number => $self->season
    })->all();

    my @players = map { $_->player } @signup;

    my $league = Games::Tournament::RoundRobin->new(league => \@players);

    my @league_table;
    my $rounds;
    my $round_num = 0;
    my $success = TableTennisLeague->model('DB')->txn_do(
        sub {
            foreach my $player (@players) {
                TableTennisLeague->model('DB::League')->create({
                    player => $player,
                    season_number => $self->season
                });

                push @league_table, {
                    name => $player,
                    score => 0,
                    played => 0,
                    won => 0,
                    drawn => 0,
                    lost => 0,
                    for => 0,
                    against => 0,
                    points_diff => 0
                };
            }

            foreach my $round (@{$league->wholeSchedule}) {
                $round_num++;
                my @games;
                foreach my $game (@{$round}) {
                    my $winner = ($game->[0] eq 'Bye' || $game->[1] eq 'Bye') ? 'Bye' : undef;
                    TableTennisLeague->model('DB::Round')->create({
                        round => $round_num,
                        season_number => $self->season,
                        player1 => $game->[0],
                        player2 => $game->[1],
                        winner => $winner
                    });

                    push @games, {
                        player1 => $game->[0],
                        player2 => $game->[1],
                        score1 => undef,
                        score2 => undef,
                        winner => undef,
                    }
                }

                $rounds->{$round_num} = \@games;

                TableTennisLeague->model('DB::Schedule')->create({
                    season_number => $self->season,
                    round => $round_num

                });
            }

            return 1;
        }
    );

    return {
        round_total => $round_num,
        rounds => $rounds,
        league_table => \@league_table,
    };
}

sub delete_season {
    my ($self) = @_;

    TableTennisLeague->model('DB::Schedule')->search({
        season_number => $self->season,
    })->delete_all();

    TableTennisLeague->model('DB::Round')->search({
        season_number => $self->season,
    })->delete_all();

    TableTennisLeague->model('DB::League')->search({
        season_number => $self->season,
    })->delete_all();

    return;
}

1;
