#!/usr/bin/perl -w
use strict;
use Test::Simple tests => 4;
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0) . '/lib';
use Transform::Html;
use Transform::Javascript;
my $html = Transform::Html->new;
my $js = Transform::Javascript->new;
my @array = (1,2);
ok($html->transform(\@array), '<ol><li>1</li><li>2</li></ol>');
ok($js->transform(\@array), "[1, 2]");
my @array2 = [ 0, 1, { 'a' => 'ah', 'b' => 'bee' }, "string" ];
ok($html->transform(\@array2),
'<ol><li>0</li><li>1</li><li><dl><dt>a</dt><dd>ah</dd><dt>b</dt><dd>bee</dd></dl></li><li>string</li></ol>');
ok($js->transform(\@array2), '[0, 1, {"a" : "ah", "b" : "bee"}, "string"]');
