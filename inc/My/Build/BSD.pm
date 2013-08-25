########################################################################
                    package My::Build::BSD;
########################################################################

use strict;
use warnings;
use parent 'My::Build::Linux';

sub make_command { 'gmake' }

1;
