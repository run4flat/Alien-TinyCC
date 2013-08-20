use strict;
use warnings;
use Test::More;
use inc::My::TestSetup;

use Alien::TinyCC;
ok(-f Alien::TinyCC->include_path . '/libtcc.h',
	'libtcc.h is in the given include path')
		or diag('include path is ' . Alien::TinyCC->include_path);

ok((grep -f, glob(Alien::TinyCC->ld_library_path . '/libtcc.*')),
	'Found libtcc dynamic library in ld_library_path')
		or diag('ld_library_path is ' . Alien::TinyCC->ld_library_path);


done_testing;
