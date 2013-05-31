#!/usr/bin/perl -w
use strict;
use Test::Simple tests => 7;
use Test::Exception;
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0) . '/lib';
use Transform::Html;
use Transform::Javascript;
my $html = Transform::Html->new;
my $js = Transform::Javascript->new;
my @array = (1,2);
ok($html->transform(\@array) eq '<ol><li>1</li><li>2</li></ol>');
ok($js->transform(\@array) eq "[1, 2]");
my @array2 = [ 0, 1, { 'a' => 'ah', 'b' => 'bee' }, "string" ];
print $html->transform(\@array2) . "\n";
print $js->transform(\@array2) . "\n";
# have a little problem with order in the hash / order list
ok($html->transform(\@array2) eq
'<ol><li>0</li><li>1</li><li><dl><dt>a</dt><dd>ah</dd><dt>b</dt><dd>bee</dd></dl></li><li>string</li></ol>'
||
'<ol><li>0</li><li>1</li><li><dl><dt>b</dt><dd>bee</dd><dt>a</dt><dd>ah</dd></dl></li><li>string</li></ol>');
ok($js->transform(\@array2) eq '[0, 1, {"a" : "ah", "b" : "bee"}, "string"]' ||
                               '[0, 1, {"b" : "bee", "a" : "ah"}, "string"]');
my @dt = ();
my $a = \@dt;
push(@dt, $a);
dies_ok { $js->transform(\@dt) } 'expecting to die';
my @dt2 = ();
my $a2 = \@dt2;
my $b = (1, $a2);
push(@dt2, $b);
dies_ok { $js->transform(\@dt2) } 'js should die';
dies_ok { $html->transform(\@dt2) } 'html should die';
