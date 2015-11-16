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

my $season_number = TableTennisLeague->config->{season_number};

my $today = DateTime->today()->ymd('-');

my $current_round = TableTennisLeague->model('DB::Schedule')->search(
    {
        start_date =>  { '<=' => $today },
        end_date => { '>=' => $today },
        'me.season_number' => $season_number
    },
    {
        prefetch => 'round'
    }
)->first();

my $params =  {
    winner => undef,
    'me.season_number' => $season_number
};
if (!$current_round) {
    print "Current round not found. Printing outstanding games for all rounds\n";
}
else {
    $params->{round} = { '<' => $current_round->round->round };
}

$params->{'player1.season_number'} = $season_number;
$params->{'player2.season_number'} = $season_number;
my @outstanding_games = TableTennisLeague->model('DB::Round')->search(
    $params,
    {
        order_by => 'me.round',
        prefetch => ['player1','player2']
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
