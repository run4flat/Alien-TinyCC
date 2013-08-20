use strict;
use warnings;
use Test::More;
use inc::My::TestSetup;

use Alien::TinyCC;

# tcc should just be in my path, so let's build a c file and run it
open my $out_fh, '>', 'test.c';
print $out_fh <<'EOF';
#include <stdio.h>

int main() {
	printf("Good to go");
	return 1;
}

EOF
close $out_fh;

END {
	unlink 'test.c';
}

my $include = join(' ', Alien::TinyCC->include_paths);
print "About to include $include\n";
my $results = `tcc $include -run test.c`;
ok($?, 'tcc was able to run');
is($results, 'Good to go', 'tcc compiled the code correctly')
	or diag("tcc printed $results");
