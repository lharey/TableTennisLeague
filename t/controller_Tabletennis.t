use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TableTennisLeague';
use TableTennisLeague::Controller::Tabletennis;

ok( request('/tabletennis')->is_success, 'Request should succeed' );
done_testing();
