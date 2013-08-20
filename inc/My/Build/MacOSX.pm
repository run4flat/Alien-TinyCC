########################################################################
                    package My::Build::MacOSX;
########################################################################

use strict;
use warnings;

use parent 'My::Build::Linux';
sub extra_config_args { '--cpu=x86-64' }

1;
