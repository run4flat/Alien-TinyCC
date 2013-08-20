use strict;
use warnings;
use Test::More;
use inc::My::TestSetup;

use Alien::TinyCC;
my $found = 0;
-f "$_/libtcc.h" and $found = 1 foreach (Alien::TinyCC->include_paths);

ok($found, 'libtcc.h is in the given include path')
	or diag('include paths are [' . join('], [', Alien::TinyCC->include_paths) . ']');

if ($^O !~ /MSWin/) {
	ok((grep -f, glob(Alien::TinyCC->ld_library_path . '/libtcc.*')),
		'Found libtcc dynamic library in ld_library_path')
			or diag('ld_library_path is ' . Alien::TinyCC->ld_library_path);
}


done_testing;
