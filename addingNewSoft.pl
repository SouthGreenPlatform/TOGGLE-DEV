#!/usr/bin/env perl

###################################################################################################################################
#
# Copyright 2014-2018 IRD-CIRAD-INRA-ADNid
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/> or
# write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.
#
# You should have received a copy of the CeCILL-C license with this program.
#If not see <http://www.cecill.info/licences/Licence_CeCILL-C_V1-en.txt>
#
# Intellectual property belongs to IRD, CIRAD and South Green developpement plateform for all versions also for ADNid for v2 and v3 and INRA for v3
# Version 1 written by Cecile Monat, Ayite Kougbeadjo, Christine Tranchant, Cedric Farcy, Mawusse Agbessi, Maryline Summo, and Francois Sabot
# Version 2 written by Cecile Monat, Christine Tranchant, Cedric Farcy, Enrique Ortega-Abboud, Julie Orjuela-Bouniol, Sebastien Ravel, Souhila Amanzougarene, and Francois Sabot
# Version 3 written by Cecile Monat, Christine Tranchant, Laura Helou, Abdoulaye Diallo, Julie Orjuela-Bouniol, Sebastien Ravel, Gautier Sarah, and Francois Sabot
#
###################################################################################################################################

use strict;
use warnings;
use localConfig;

#This tool will allows developer to add easily a new software in TOGGLe

print "\nWelcome to the marvelous world of TOGGLe, the best workflow manager you have ever dreamed of (especially compared to this bullshit of Galaxy...)\n";

#Asking for the module name, ie the generic tool
my $module="";
while ($module eq "")
{
    print "\nWhat is the name of your tool (e.g. bwa) ?\n";
    $module = <STDIN>;
    chomp $module;
}

#Asking for the function name, ie the specific tool itself
my $function = "";
while ($function eq "")
{
    print "\nWhat is the name of your function (e.g. bwaAln for bwa aln) ?\n";
    $function = <STDIN>;
    chomp $function;
}

#asking for IN, OUT mandatory and version

my $in = "";
my $out = "";
my $mandatory ="";
my $version = "";
my $testParams = "";

while ($in eq "")
{
    print "\nWhat are the different entry formats of your tool, separated by commas (e.g. fastq or fastq,fasta) ?\n";
    $in = <STDIN>;
    chomp $in;
}

while ($out eq "")
{
    print "\nWhat are the different output formats of your tool, separated by commas (e.g. fastq or fastq,fasta) ? \n**NOTE if your tool is a dead-end one, such as FASTQC, please provide NA as output format.**\n";
    $out = <STDIN>;
    chomp $out;
}

print "\nAre there any mandatory requirement as option for your tool (e.g. reference or gff) ? \n**NOTE if none leave empty.**\n";
$mandatory = <STDIN>;
chomp $mandatory;

while ($version eq "")
{
    print "\nHow do you obtain the version of your tool (e.g. 'bwa 2>&1| grep version' or 'java --version | grep Version' \n";
    $version = <STDIN>;
    chomp $version;
}

#The testParams value will be used in the fileConfigurator.pm module for block test.
print "\n'Are there any test parameters to include for testing (e.g. '-n 5' for bwa aln tests ) ?\n";
$testParams = <STDIN>;
chomp $testParams;

#Standard command line
my $commandLine="";
while ($commandLine eq "")
{
    print "\nWhat is the standard command line to launch your tool ?\n\t- A file in must be written FILEIN\n\t- a file out must be written FILEOUT\n\t- Options location must be written as [options]\n\t- Reference must be written as REFERENCE\n";
    print "\nAn example for bwa aln will be:\n\tbwa aln [options] FILEOUT REFERENCE FILEIN\n\n";
    print "\n**NOTE You may have to adapt and correct this command at this end...\n";
    $commandLine=<STDIN>;
    chomp $commandLine;
}

# Create the module if needed
$module = lc $module;
my $moduleFile = $module.".pm";

unless (-f "$toggle/modules/$moduleFile")
{   #We create the module if it does not exists
    open (my $fhTemplate, "<", "$toggle/modules/module_template.pm") or die ("\nCannot open the module_template file:\n$!\n");
    open (my $fhModule, ">", "$toggle/modules/$moduleFile") or die  ("\nCannot create the $moduleFile file:\n$!\n");
    
    while (my $line = <$fhTemplate>)
    {
        if ($line =~ m/^package/)
        {
            $line =~ s/module_template/$module/;
        }
        print $fhModule $line;
    }
    close $fhTemplate;
    close $fhModule;
}

#Create the function

#Testing if exists
my $subName = "sub $function";
my $grep = `grep $subName $toggle/modules/$moduleFile`;
chomp $grep;
if ($grep)
{   #the function exists...
    die "\nThe function already exists, will quit...\n";
}

#Creating the text
my $subText=$subName."\n{\n";

