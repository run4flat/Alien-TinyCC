use strict;
use warnings;

use Config;
use File::Spec;

# Get the path to a place we have some hope of having permission to install,
# and having some hope it is in the path. (Check this!!!)
my ($prefix_volume, $prefix_path) = File::Spec->splitpath($Config{installsitebin});

# For unixen, we need a path that serves as a good prefix
my @dirs = File::Spec->splitdirs($prefix_path);
pop @dirs;
my $linux_prefix = File::Spec->catpath($prefix_volume, File::Spec->catdirs(@dirs));

# For windows, we need a directory that's in the path. This ought not be
# Perl's binary install directory, as there are likely better candidates,
# but we'll have to start there and see what else we can find in the path.
my $win_prefix = File::Spec->catpath($prefix_volume, $prefix_path);
my $tentative_win_prefix = File::Spec->rel2abs(File::Spec->catpath($prefix_volume,
  File::Spec->catdirs(@dirs, '..', '..', 'c', 'bin')));
# Does this directory exist in the path? If so, use it.
$win_prefix = $tentative_win_prefix
  if grep { $_ eq $tentative_win_prefix } File::Spec->path();

use Module::Build;
my $class;

if ($^O =~ /MSWin/) {
  $class = Module::Build->subclass(
    class => "Module::Build::TCC",
    code => <<SUBCLASS );
    
    sub ACTION_build {
      my \$self = shift;
      
      # move into the source directory
      chdir 'src\\win32';
      
      # Perform the build custom for Windows
      system('build-tcc.bat');
      
      # Copy the files to the same directory as Perl itself
      recursive_copy('$win_prefix');
      
      \$self->SUPER::ACTION_install;
    }
    
    use File::Copy;
    sub recursive_copy {
      my \$target_dir = shift;
      for my \$file (glob '*') {
        if (-d \$file) {
          mkdir "\$target_dir/\$file";
          chdir \$file;
          recursive_copy();
          chdir '..';
        }
        elsif (-f \$file) {
          copy(\$file => "\$target/\$file");
        }
      }
    }
SUBCLASS
}
else {
  # Special handling for Cygwin and Mac
  my $extra_args = '';
  $extra_args = '--enable-cygwin' if $^O =~ /Cygwin/;
  $extra_args = '--cpu=x86-64' if $^O eq 'darwin';
  $class = Module::Build->subclass(
    class => "Module::Build::TCC",
    code => <<SUBCLASS );
    
    sub ACTION_build {
      my \$self = shift;
      
      # move into the source directory and perform configure, make, and install
      chdir 'src';
      
      # normal incantation
      system('./configure --prefix=$linux_prefix $extra_args');
      system('make');
      system('make install');
      
      \$self->SUPER::ACTION_install;
    }
SUBCLASS
}

$class->new(
  module_name => 'Alien::TinyCC',
  dist_abstract => 'Ensure the Tiny C Compiler is installed on your system',
  dist_author => 'David Mertens <dcmertens.perl@gmail.com>',
  license => 'perl',
)->create_build_script;
