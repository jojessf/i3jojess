#!/usr/bin/perl
use Sys::Hostname;
use Getopt::Lazier;

my ($opt, @DARG) = Getopt::Lazier->new(@ARGV);

$opt->{host} //= hostname;
$opt->{bakroot} //= "/nu/inf/i3/i3jojess/".$opt->{host}."/";

chdir($ENV{HOME}) or die;

# main config uwu
system("cp -r " . $opt->{bakroot} . ".config/i3 ~/.config/");


# ROFI THEME
system("cp -r " . $opt->{bakroot} . ".config/rofi ~/.config/");
system("cp ".$opt->{bakroot}.".i3* ~/");
system("mkdir ~/.local/share/rofi");
system("mkdir ~/.local/share/rofi/themes");
system("cp -r " . $opt->{bakroot} . ".local/share/rofi/themes/jojess.rasi ~/.local/share/rofi/themes/");

# LINK IT UP
system("ln -s .config/i3/config i3.config");
system("ln -s .i3blocks.conf i3.blocks");
system("ln -s .i3status.conf i3.status");
