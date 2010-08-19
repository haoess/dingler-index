use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'Dingler' }
BEGIN { use_ok 'Dingler::Controller::Records' }

ok( request('/records')->is_success, 'Request should succeed' );
done_testing();
