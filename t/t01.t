#!/usr/bin/perl
package Plo::h_params;
sub new  {
    my $class = shift;
    bless ( ($#_ == 0) ? shift : {@_}, ref($class) || $class);
}
sub name { $_[0]->{id} }
sub is_notreq {$_[0]->{is_notreq} }
sub comment {$_[0]->{raw_str}}
1;
package main;
use strict;
use warnings;
use Test::More tests => 6;    # last test to print
use Data::Dumper;
use v5.10;
use Regexp::Grammars;
use Plosurin;


my $p   = new Plosurin::;
my $str = <<'TXT';
{namespace Test.more}
/**
 * Commets text
 * @param test Test param
 * @param mode Mode for tempalate
 */
{template .Hello}
<p>Ok</p> 
asdad
{/template}
TXT
isa_ok $p->parse($str),"Plo::File","return object";
$str = <<'TXT2';
{namespace rname.sample}
/**
  * Comment line1
  * continue
  * @param? par1 Some comment
  * @param par2 Some comment
 */
{template .Hello}
  <div>Test</div>
{/template}

/**
  * Comment line
  * @param par1 Some comment
  * @param par2 Some comment
 */
{template .Hello1}
  <div>Test</div>
{/template}
TXT2
my $f1 = $p->parse($str);
is scalar($f1->templates), 2,"2 templates";
is $f1->namespace,"rname.sample", 'check namespace';
my ($t1,$t2) = $f1->templates;
is $t1->name, '.Hello','template name';
ok ($t1->comment =~ m/Comment .* line1 .* continue/xs,"more than 1 comment line ");
is $t1->params(), 2 ,"get params";

is_deeply [ sort keys %{ (Plosurin::Context::->new($f1))->name2tmpl } ],
      [
          'rname.sample.Hello',
          'rname.sample.Hello1'
        ], 'get list of names';

$str = <<'TXT2';
{namespace Main.sample}
/**
  * Comment line1
  * continue
  * @param? par1 Some comment
  * @param par2 Some comment
 */
{template .sub}
  <div>Test</div>
{/template}

/**
  * Comment line
  * @param par1 Some comment
  * @param par2 Some comment
 */
{template .main}
  <div>Test</div>
  {call .sub data="all"/}
{/template}
TXT2

my $file = $p->parse($str);
ok ($p->as_perl5({package=>"MyApp"},$file) =~ m/Main_sample_sub/, "convert call"); exit;

our $file = "Test file";
my $q = qr{
     <extends: Plosurin::Template::Grammar>
    <matchline>
    #    <debug:step>
    \A <File> \Z
}xms;
if ($str =~ $q) {
    say Dumper({%/})
}
#my $tfile = $p->parse( $str,$file);
#say $p->as_perl5({package=>"Test"},$tfile);

