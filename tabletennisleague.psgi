use strict;
use warnings;

use TableTennisLeague;

my $app = TableTennisLeague->apply_default_middlewares(TableTennisLeague->psgi_app);
$app;

