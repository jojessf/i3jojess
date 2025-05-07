#!/usr/bin/perl
use Sys::Hostname;
use Getopt::Lazier;
use File::Path qw(make_path);
use File::Copy qw(copy move);

my ($opt, @DARG) = Getopt::Lazier->new(@ARGV);

$opt->{host} //= hostname;
$opt->{bakroot} //= "/nu/inf/i3/i3jojess/".$opt->{host}."/";
mkdir ( $opt->{bakroot} ) if ! -d $opt->{bakroot};
$opt->{indir} //= $ENV{HOME};
#$opt->{bakfils} //= "\.conf,\.jsonc,\.css,\.xml";
$opt->{bakfils} //= "i3";
$opt->{bakstamp} //= `date +"%Y%m%d%H%M%S"`;
chomp($opt->{bakstamp});

chdir($opt->{indir}) or die "no indir " . __LINE__ . "\n";
my @FIs;
while (<*>) { push(@FIs, $_) }
while (<.*>) { push(@FIs, $_) }
FI: foreach $_ (@FIs) {
   my $skip = 1;
   foreach my $glob (split(",", $opt->{bakfils})) {
      $skip = 0 if m/$glob/;
   }
   next FI if $skip;
   my $fi = $_;
   my $fipath = readlink($_);
   my $fidir  = $fipath;
      $fidir =~ s/^(.*\/).*?$/$1/;
      $fidir =~ s/^$ENV{HOME}\///g;
      $fipath =~ s/^$ENV{HOME}\///g;
   print "FI:" . $fi . "\t". $fipath . "\n";   
   if ( -d $fidir ) { 
      print "MKDIR ".$opt->{bakroot} . $fidir . "\n";
      make_path($opt->{bakroot} . $fidir);
      die "$fidir\n" if ! -d $opt->{bakroot} . $fidir;
   }
   next FI if ! -e $fi;
   $fipath = $fi if length($fipath)==0;
   print "COPY $fipath, ".$opt->{bakroot}.$fipath . "\n";
   next FI if $opt->{nocp};
   copy($fipath, $opt->{bakroot}.$fipath) or do {
      print "ERROR, next\n";  
   };
}
exit;
chdir($opt->{bakroot}) or die;
chdir("../") or die;
system("zip -r ".$opt->{host}.".".$opt->{bakstamp}.".zip ".$opt->{bakroot} );
mkdir("bak");
move($opt->{host}.".".$opt->{bakstamp}.".zip", "bak/");
