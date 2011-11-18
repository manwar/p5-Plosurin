#===============================================================================
#
#  DESCRIPTION:  grammar
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
package Plosurin::Grammar;
use strict;
use warnings;
use v5.10;
use Regexp::Grammars;

=head2 Plosurin::Template::Grammar - template file grammar

    qr{
    my $r = qr{
       <extends: Plosurin::Template::Grammar>
        <matchline>
        \A <File> \Z
    }xms;
    if ( $txt =~ $r) {
        ...
    } 
    
=cut
qr{
    <grammar: Plosurin::Template::Grammar>
    <objrule: Plo::File>
    <namespace>(?{ $MATCH{file} = $file//"linein"})
    <[templates=template]>+ % <_sep=(\s+)> \s+
    <objtoken: Plo::template> <header> <template_block>
    <rule: namespace> \{namespace <id>\} \n+
    <rule: id>  [\.\w]+
    <rule: header> \/\*{2}\n (?: <[h_params]>|<[h_comment]> )+ <javadoc_end> 
        | \/\*\n <matchline><fatal:(?{say "JavaDoc must start with /**! at $file line $MATCH{matchline} : $CONTEXT" })>

    <rule: javadoc_end>\*\/
        | <matchline><fatal:(?{say "JavaDoc must end with */! at $file line $MATCH{matchline} : $CONTEXT" })>

    <rule: h_comment> \* <raw_str>
    <rule: raw_str> [^@\n]+$
    <objrule: Plo::h_params> \* \@param<is_notreq=(\?)>? <id> <raw_str>
    
    <rule: template_block>
            <start_template>
            <raw_template=(.*?)>
#            <raw_template>
            <stop_template>
    <rule: raw_template>  (!? <stop_template> ) .*?

    <rule: start_template> \{template <name=(\.\w+)>\} 
    | <matchline><fatal:(?{say "Bad template definition at $file line $MATCH{matchline} : $CONTEXT" })>
    <rule: stop_template>  \{\/template\}
  }xms;

=head2 Plosurin::Grammar - soy grammar

    qr{
    my $r = qr{
     <extends: Plosurin::Grammar>
    \A  <[content]>* \Z
    }xms;
    if ( $txt =~ $r) {
        ...
    } 
    
=cut

qr{
     <grammar: Plosurin::Grammar>
#    \A  <[content]>* \Z
    <objtoken: Soy::Node=content><matchpos><matchline>
        (?:

         <obj=raw_text>
        |<obj=command_print>
        |<obj=command_include>
        |<obj=command_if>
        |<obj=command_call_self>
        |<obj=command_call>
        |<obj=raw_text_add>

        )
    <objrule: Soy::raw_text=raw_text_add><matchpos>(.+?) 
#    <require: (?{ length($CAPTURE) > 0 })>
#        <fatal:(?{say "May be command ? $MATCH{raw_text_add} at $MATCH{matchpos}"})>
    <objrule: Soy::command_print>
                   \{print <variable>\}
    <objrule: Soy::command_include>
              \{include <[attribute]>{2} % <_sep=(\s+)> \}
             |\{include <matchpos><fatal:(?{say "'Include' require 2 attrs at $MATCH{matchpos}"})>

    <token: attribute> <name=(\w+)>=['"]<value=(?: ([^'"]+) )>['"]

    <token: variable> \$?\w+ 
    <objtoken: Soy::expression> .*?

    <objrule:  Soy::raw_text> [^\{]+
    <objrule: Soy::command_if> \{if <expression>\} <[content]>+?
                        (?:
                        <[commands_elseif=command_elseif]>*
                        <command_else>
                        )?
                    \{\/if\}
    <objrule: Soy::command_elseif><matchpos><matchline> \{elseif <expression>\} <[content]>+?
    <objrule: Soy::command_else><matchpos><matchline> \{else\} <[content]>+?

    #self-ending call block
    <objrule: Soy::command_call_self> \{call <tmpl_name=([\.\w]+)> <[attribute]>* % <_sep=(\s+)> \/\}
    <objrule: Soy::command_call> \{call <tmpl_name=([\.\w]+)> \}
                               <[content=param]>*
                                \{\/call\}

    <token: param> 
        <matchpos><matchline> 
        (?: <obj=command_param_self> | <obj=command_param> )
    <objrule: Soy::command_param_self> \{param <name=(.*?)> : <value=(.*?)> \/\}
    <objrule: Soy::command_param> \{param <name=(.*?)> \}
                    <[content]>+?
                  \{\/param\}
}xms;

1;

