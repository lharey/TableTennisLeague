use strict;
use warnings;

use FindBin qw/$RealBin/;
use lib "$RealBin/lib";
use TableTennisLeague;
use Plack::Builder;

builder {
    enable 'CrossOrigin',
        origins         => '*',
        headers         => '*',
        methods         => '*',
        expose_headers  => '*';

    my $app = TableTennisLeague->psgi_app;

    $app = TableTennisLeague->apply_default_middlewares($app);
}
