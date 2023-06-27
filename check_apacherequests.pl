#!/usr/bin/perl -w

use POSIX;
use strict;
use File::Basename;
use Getopt::Long;

use vars qw(
	    $opt_help
	    $opt_usage
	    $opt_version
	    $opt_critical
	    $opt_warning
	   );

sub print_usage();
sub print_help();

my $progname = basename($0);

my %ERRORS = ('UNKNOWN'  => '-1',
	      'OK'       => '0',
	      'WARNING'  => '1',
	      'CRITICAL' => '2');

Getopt::Long::Configure('bundling');
GetOptions
  (
   "c=s" => \$opt_critical, "critical=s" => \$opt_critical,
   "w=s" => \$opt_warning,  "warning=s"  => \$opt_warning,
   "h"   => \$opt_help,     "help"       => \$opt_help,
                            "usage"      => \$opt_usage,
   "V"   => \$opt_version,  "version"    => \$opt_version
  ) || die "Try `$progname --help' for more information.\n";

sub print_usage() {
  print "Usage: $progname -w WARNING -c CRITICAL\n";
  print "       $progname --help\n";
  print "       $progname --version\n";
}

sub print_help() {
  print "$progname - check current apache requests\n";
  print "Options are:\n";
  print "  -c, --critical \n";
  print "  -w, --warning \n";
  print "  -h, --help                      display this help and exit\n";
  print "      --usage                     display a short usage instruction\n";
  print "  -V, --version                   output version information and exit\n";
}

if ($opt_help) {
  print_help();
  exit $ERRORS{'UNKNOWN'};
}

if ($opt_usage) {
  print_usage();
  exit $ERRORS{'UNKNOWN'};
}

if ($opt_version) {
  print "$progname 0.0.1\n";
  exit $ERRORS{'UNKNOWN'};
}

##### DO THE WORK ######################################################################

my $value=`/usr/bin/lynx -dump localhost/server-status?auto | /usr/bin/awk '/^Busy/ {print \$2}'`;
chomp($value);
my $state="OK";

if ($opt_warning && $opt_critical) {

  # generate status
  if ($value >= $opt_warning) {$state="WARNING";}
  if ($value >= $opt_critical) {$state="CRITICAL";}
  
  print "$state - $value current apache requests | 'apache requests'=".$value.";".$opt_warning.";".$opt_critical."\n";
  exit $ERRORS{$state};

}
else {
  print_usage();
  exit $ERRORS{'UNKNOWN'};
}

########################################################################################
