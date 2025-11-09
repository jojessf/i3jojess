#!/usr/bin/perl
use Data::Dumper;
use Sys::Hostname;
use Getopt::Lazier;
use File::Path qw(make_path);
use File::Copy qw(copy move);

my ($opt, @DARG) = Getopt::Lazier->new(@ARGV);

die "mount stuff" if ( ! -d "/nu/inf" );

$opt->{host} //= hostname;
$opt->{bakroot} //= "/nu/inf/i3/i3jojess/".$opt->{host}."/";
mkdir ( $opt->{bakroot} ) if ! -d $opt->{bakroot};
mkdir ( $opt->{bakroot}."bin" ) if ! -d $opt->{bakroot}."bin";
$opt->{indir} //= $ENV{HOME};
#$opt->{bakfils} //= "\.conf,\.jsonc,\.css,\.xml";
$opt->{bakfils} //= "i3|hdmi|pipewire"; # if $ENV{DEBUG};";
$opt->{bakstamp} //= `date +"%Y%m%d%H%M%S"`;
chomp($opt->{bakstamp});

chdir($opt->{indir}) or die "no indir " . __LINE__ . "\n";
my @FIs;
while (<bin/*>) { push(@FIs, $_) }
while (<*>) { push(@FIs, $_) }
while (<.*>) { push(@FIs, $_) }
#print Dumper([ @FIs ])."\n" if $ENV{DEBUG};
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
   print "FI:" . $fi . "\t". $fipath . "\n" if $ENV{DEBUG};
   if ( -d $fidir ) { 
      print "MKDIR ".$opt->{bakroot} . $fidir . "\n" if $ENV{DEBUG};
      make_path($opt->{bakroot} . $fidir);
      die "$fidir\n" if ! -d $opt->{bakroot} . $fidir;
   }
   next FI if ! -e $fi;
   $fipath = $fi if length($fipath)==0;
   print "COPY $fipath, ".$opt->{bakroot}.$fipath . "\n"; # if $ENV{DEBUG};
   next FI if $opt->{nocp};
   copy($fipath, $opt->{bakroot}.$fipath) or do {
      print "ERROR, next\n";  
   };
}
print "\n" . $opt->{bakroot} . "\n";
exit;
chdir($opt->{bakroot}) or die;
chdir("../") or die;
system("zip -r ".$opt->{host}.".".$opt->{bakstamp}.".zip ".$opt->{bakroot} );
mkdir("bak");
move($opt->{host}.".".$opt->{bakstamp}.".zip", "bak/");

