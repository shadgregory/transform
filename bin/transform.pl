#/usr/bin/env perl
use 5.014;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0) . '/lib';
use Transform::Html qw(transform);
use Transform::Javascript qw(transform);

my $html = Transform::Html->new();
my $js   = Transform::Javascript->new();
if ( $ARGV[0] eq "--htmltidy" && $ARGV[1] ) {
    my $tidy = HTML::Tidy->new(
        {   clean     => 1,
            indent    => 1,
            tidy_mark => 0
        }
    );
    $tidy->ignore( type => 1, type => 2 );
    open( FILE, $ARGV[1] ) or die $_;
    my @lines = <FILE>;
    foreach my $line (@lines) {
        my $html_line = $html->transform( eval($line) );
        $tidy->parse( "test.html", $html_line );
        say $tidy->clean($html_line);
    }
    close(FILE);
}
if ( $ARGV[0] eq "--html" && $ARGV[1] ) {
    open( FILE, $ARGV[1] ) or die $_;
    my @lines = <FILE>;
    foreach my $line (@lines) {
        say "\n", $html->transform( eval($line) );
    }
    close(FILE);
}
elsif ( $ARGV[0] eq "--js" && $ARGV[1] ) {
    open( FILE, $ARGV[1] ) or die $_;
    my @lines = <FILE>;
    foreach my $line (@lines) {
        say "\n", $js->transform( eval($line) );
    }
    close(FILE);
}
else {
    say "Usage : perl transform.pl --arg file";
}
