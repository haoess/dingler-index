use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Dingler';
use Dingler::Controller::Admin::Timeline;

ok( request('/admin/timeline')->is_success, 'Request should succeed' );
done_testing();
