#/usr/bin/env perl

=head1 NAME

remove_player.pl

=head1 DESCRIPTION

Removes a player from the leafuer, resetting any scores

=head1 SYNOPSIS

  perl remove_player.pl -p 'Han Solo'

=cut

use 5.10.0;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use TableTennisLeague;
use Getopt::Long::Descriptive;

my $season_number = TableTennisLeague->config->{season_number};

my ($opt, $usage) = describe_options(
    '%c %o',
    ['player|p=s' => 'Player full name.', { required => 1 }],
    ['help'        => 'Print usage and exit']
);

print($usage->text) and exit if $opt->help;

my $player_name = $opt->player;

say "Removing player $player_name from season $season_number";

my @games = TableTennisLeague->model('DB::Round')->search({
    'me.season_number' => $season_number,
    '-or' => {
        'me.player1' => $player_name,
        'me.player2' => $player_name
    },
    'player1.season_number' => $season_number,
    'player2.season_number' => $season_number
},
{
    prefetch => ['player1','player2']
})->all();

my $total = scalar @games;
foreach my $game (@games) {
    my $player1 = $game->player1;
    my $player2 = $game->player2;
    my $winner = $game->winner;
    my $msg;
    if ($winner) {
        my $players_score;
        my $opponents_score;
        my $opponent;
        if ($game->player1->player eq $player_name) {
            $players_score = $game->score1;
            $opponents_score = $game->score2;
            $opponent = $game->player2;
        }
        else {
            $players_score = $game->score2;
            $opponents_score = $game->score1;
            $opponent = $game->player1;
        }

        $msg .= "$player_name ($players_score) V  " . $opponent->player . "($opponents_score): Winner $winner\n";
        $msg .= "        P  W  L  F  A  D  S\n";
        my @before = ($opponent->played, $opponent->won, $opponent->lost, $opponent->for, $opponent->against, $opponent->points_diff, $opponent->score);
        $msg .= 'Before: ' .  join ' ', @before;

        my $for = $opponent->for - $opponents_score;
        my $against = $opponent->against - $players_score;

        my $params = {
            played => $opponent->played - 1,
            lost => ($winner eq $player_name) ? ($opponent->lost - 1) : $opponent->lost,
            won => ($winner eq $player_name) ? $opponent->won : ($opponent->won - 1),
            for => $for,
            against => $against,
            score => ($winner eq $player_name) ? $opponent->score : ($opponent->score - 3),
            points_diff => $for - $against
        };

        my @after = ($params->{played}, $params->{won}, $params->{lost}, $for, $against, $params->{points_diff}, $params->{score});
        $msg .= "\nAfter:  " .  join ' ', @after;

        # Update opponents game
        $opponent->update($params);

    }

    say $msg if $msg;
    # Delete the game
    $game->delete;
}

# Delete the league entry
TableTennisLeague->model('DB::League')->find({
    'me.season_number' => $season_number,
    'player' => $player_name
})->delete();
