########################################################################
                    package My::Build::MacOSX;
########################################################################

use strict;
use warnings;

use parent 'My::Build::Linux';

# Figure out if gcc thinks the 64-bit flags are set:
my $extra_config_args = '--cpu=x86';
open my $out_fh, '>', '_test.h';
print $out_fh "\n";
close $out_fh; 
$extra_config_args .= '-64' if `gcc -E -dM _test.h` =~ /__x86_64__/;
unlink '_test.h';

sub extra_config_args { $extra_config_args }

# Let's resolve the compiler. If it's llvm, we need to remove the
# -march=native, if present, from the compiler environment variables.

my $compiler = $ENV{cc} || '/usr/bin/gcc';
while (-l $compiler) {
    $compiler = readlink $compiler;
    if ($compiler =~ /llvm/) {
        # If we found the llvm compiler, clean out the environment variables
        for my $varname ( qw< CFLAGS CPPFLAGS > ) {
            next unless exists $ENV{$varname};
            $ENV{$varname} =~ s/-march-native//;
        }
    }
}

1;
