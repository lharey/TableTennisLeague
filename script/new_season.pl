#!/usr/bin/env perl

=head1 NAME

new_season.pl

=head1 DESCRIPTION

Sets up the data for a the next season

=head1 SYNOPSIS

  perl new_season.pl --season 2

=cut

use 5.10.0;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Getopt::Long::Descriptive;
use Games::Tournament::RoundRobin;
use Path::Tiny;
use TableTennisLeague;
use TableTennisLeague::Utils;

my ($opt, $usage) = describe_options(
    '%c %o',
    ['season|s=s' => 'Season number.', { required => 1 }],
    ['overwrite|o' => 'Will delete any existing data for that season.', { default => 0 }],
    ['help'        => 'Print usage and exit']
);

print($usage->text) and exit if $opt->help;

# Backup existing db
my $db_file = path($FindBin::Bin,'..','table_tennis.db');

if ($db_file->exists) {
    warn "BACKING UP DB";
    $db_file->copy(path($FindBin::Bin,'..','table_tennis.db.backup')->canonpath);
}

my $utils = TableTennisLeague::Utils->new({season => $opt->season});

# Do we already have data for that season
my @league = TableTennisLeague->model('DB::League')->search({
    season_number => $opt->season
})->all();

if (scalar @league && !$opt->overwrite) {
    die "Season " . $opt->season . " has already been created. To overwrite  specify --overwite or -o";
}
elsif (scalar @league) {
    $utils->delete_season();
}

my $season = $utils->create_new_season();

if ($season) {
    say "Season " . $opt->season . " created";
    say "Round total: " . $season->{round_total};
}
else {
    say "oops, something went wrong!";
}

exit;
