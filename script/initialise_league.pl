#!/usr/bin/env perl

=head1 NAME

initialise_league.pl

=head1 DESCRIPTION

Sets up the data for a new league

=head1 SYNOPSIS

  perl initialise_league.pl --players players.yml

=cut

use strictures;
use FindBin qw/$RealBin/;
use Getopt::Long::Descriptive;
use YAML::XS qw(LoadFile DumpFile);
use Games::Tournament::RoundRobin;
use JSON::MaybeXS;
use Path::Tiny;
use DBI;

use DDP;

my ($opt, $usage) = describe_options(
    '%c %o',
    ['players|p=s' => 'Full File path of players yml file.', { default => "$RealBin/../root/static/data/players.yml"}],
    ['games|g=s'  => 'Full File path of games yml file to be generated.', { default => "$RealBin/../root/static/data/games.json"}],
    ['help'        => 'Print usage and exit']
);

print($usage->text) and exit if $opt->help;

my $players = LoadFile($opt->players);

my $league = Games::Tournament::RoundRobin->new(league => $players);

# Backup existing db
my $db_file = path("$RealBin/../table_tennis.db");
if ($db_file->exists) {
    $db_file->copy("$RealBin/../table_tennis.db.backup");
}

my $dsn = "DBI:SQLite:dbname=table_tennis.db";
my $dbh = DBI->connect($dsn, '', '', { RaiseError => 1 })
                      or die $DBI::errstr;

my $sql = qq (
    DROP TABLE main.audit_log;
);
my $res = eval { $dbh->do($sql); };

$sql = qq (
    DROP TABLE main.schedule;
);
$res = eval { $dbh->do($sql); };

$sql = qq (
    DROP TABLE main.rounds;
);
$res = eval { $dbh->do($sql); };

$sql = qq (
    DROP TABLE main.league;
);
$res = eval { $dbh->do($sql); };



$sql = qq (
    CREATE TABLE main.league(
        player TEXT  PRIMARY KEY NOT NULL,
        score INT NOT NULL DEFAULT 0,
        played INT NOT NULL DEFAULT 0,
        won INT NOT NULL DEFAULT 0,
        drawn INT NOT NULL DEFAULT 0,
        lost INT NOT NULL DEFAULT 0,
        for INT NOT NULL DEFAULT 0,
        against INT NOT NULL DEFAULT 0,
        points_diff INT NOT NULL DEFAULT 0
    );
);
$res = $dbh->do($sql);
if($res < 0){
   print $DBI::errstr;
} else {
   print "league table created\n";
}

$sql = qq (
    CREATE TABLE main.rounds(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        round INT NOT NULL,
        player1 TEXT NOT NULL,
        player2 TEXT NOT NULL,
        score1 INT DEFAULT 0,
        score2 INT DEFAULT 0,
        winner TEXT,
        FOREIGN KEY(player1)
            REFERENCES league(player)
        FOREIGN KEY(player2)
            REFERENCES league(player)
    );
);
$res = $dbh->do($sql);
if($res < 0){
   print $DBI::errstr;
} else {
   print "rounds table created\n";
}

$sql = qq (
    CREATE TABLE main.schedule(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        round INT NOT NULL,
        start_date TEXT,
        end_date TEXT,
        FOREIGN KEY(round)
            REFERENCES rounds(round)
    );
);
$res = $dbh->do($sql);
if($res < 0){
   print $DBI::errstr;
} else {
   print "schedule table created\n";
}

$sql = qq (
    CREATE TABLE main.audit_log(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ip_address TEXT,
        audit_date TEXT,
        action TEXT,
        path TEXT,
        content TEXT
    );
);
$res = $dbh->do($sql);
if($res < 0){
   print $DBI::errstr;
} else {
   print "audit_log table created\n";
}

my @league_table;
foreach my $player (sort @{$players}) {
    if ($player ne 'Bye') {
        $dbh->do(
            qq(INSERT INTO main.league ( player ) VALUES ( ? );),
            undef,
            $player
        ) or die $dbh->errstr;

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
}

my $rounds;
my $round_num = 0;

foreach my $round (@{$league->wholeSchedule}) {
    $round_num++;
    my @games;
    foreach my $game (@{$round}) {
        $sql = qq (
            INSERT INTO main.rounds (round, player1, player2)
            values (?,?,?);
        );
        if ($game->[0] ne 'Bye' && $game->[1] ne 'Bye') {
            my @bind_vars = ($round_num, $game->[0], $game->[1] );
            $dbh->do(
                $sql,
                undef,
                @bind_vars
            ) or die $dbh->errstr;
        }

        push @games, {
            player1 => $game->[0],
            player2 => $game->[1],
            score1 => undef,
            score2 => undef,
            winner => undef,
        }
    }

    $rounds->{$round_num} = \@games;

    $dbh->do(
        qq (
            INSERT INTO main.schedule (round)
            values (?);
        ),
        undef,
        $round_num
    ) or die $dbh->errstr;
}

$dbh->disconnect;

my $output_file = path($opt->games);
if ($output_file->exists) {
    $output_file->copy($opt->games . '.backup');
}

my $json = JSON::MaybeXS->new->pretty(1);
open my $fh,">", $output_file->canonpath or die "Unable to open file " . $output_file->canonpath . ": $!";
print $fh $json->encode({
    round_total => $round_num,
    rounds => $rounds,
    league_table => \@league_table,
    current_round => 1
});
close $fh;



#DumpFile($opt->games,$rounds);

#### We want to produce json data for the league to use
### Or shall we have local sql database?????

### Also think about what if a new player wants to join part way through

### Or a player want to retire

#my $test = LoadFile($opt->games);

exit;
