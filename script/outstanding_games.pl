#/usr/bin/env perl

=head1 NAME

outstanding_games.pl

=head1 DESCRIPTION

Lists the outstanding games

=head1 SYNOPSIS

  perl outstanding_games.pl

=cut

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use TableTennisLeague;

my $today = DateTime->today()->ymd('-');

my $current_round = TableTennisLeague->model('DB::Schedule')->search(
    {
        start_date =>  { '<=' => $today },
        end_date => { '>=' => $today }
    },
    {
        prefetch => 'round'
    }
)->first();

my @outstanding_games = TableTennisLeague->model('DB::Round')->search(
    {
        round => { '<' => $current_round->round->round },
        winner => undef
    },
    {
        order_by => 'me.round'
    }
)->all();

my $round_number = 0;
foreach my $game (@outstanding_games) {
    if ($round_number != $game->round) {
        $round_number = $game->round;
        print "\nRound $round_number\n";
    }

    print $game->player1->player . ' v ' . $game->player2->player ."\n";
}


exit;