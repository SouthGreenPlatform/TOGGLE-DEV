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
use Data::Dumper;
use localConfig;

#This tool will allows developer to add easily a new software in TOGGLe

print "\nWelcome to the tenebrous world of TOGGLe, the best workflow manager you have ever dreamed of (especially compared to this bullshit of Galaxy...)\n";

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
    $function =~ s/\s//g;
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

#Testing if exists

my $subName = "sub $function";
my $grepCom = "grep -c \"$subName\" $toggle/modules/$moduleFile 2>/dev/null";
my $grep = `$grepCom`;
chomp $grep;
if ($grep)
{   #the function exists...
    die "\nThe function already exists, will quit...\n";
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
    $in =~ s/\s//g;
}

while ($out eq "")
{
    print "\nWhat are the different output formats of your tool, separated by commas (e.g. fastq or fastq,fasta) ? \n**NOTE if your tool is a dead-end one, such as FASTQC, please provide NA as output format.**\n";
    $out = <STDIN>;
    chomp $out;
    $out =~ s/\s//g;
}

print "\nAre there any mandatory requirement as option for your tool (e.g. reference or gff) ? \n**NOTE if none leave empty.**\n";
$mandatory = <STDIN>;
chomp $mandatory;

while ($version eq "")
{
    print "\nHow do you obtain the version of your tool (e.g. 'bwa 2>&1| grep version' or 'java --version | grep Version') \n";
    $version = <STDIN>;
    chomp $version;
    #Testing if the command version is ok
    `$version`or $version ="";
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



#Create the function

#Creating the text
my $subText=$subName."\n{\n";

$subText.= '#PLEASE CHECK IF IT IS OK AT THIS POINT!!'."\n\t".'my ($fileIn,$fileOut,$optionsHachees) = @_;'."\n";

#Testing the type of IN OUT and mandatory to generate the input output files variables

$subText.= "\tmy \$validation = 0;\n\tswitch (1)\n\t{";

my %formatValidator = (
                        fasta =>"\n\t\t".'case ($fileIn =~ m/fasta|fa|fasta\.gz|fa\.gz$/i){$validation = 1 if (checkFormat::checkFormatFasta($fileIn) == 1)}',
                        fastq =>"\n\t\t".'case ($fileIn =~ m/fastq|fq|fastq\.gz|fq\.gz$/i){$validation = 1 if (checkFormat::checkFormatFastq($fileIn) == 1)}',
                        sam => "\n\t\t".'case ($fileIn =~ m/sam$/i){$validation = 1 if (checkFormat::checkFormatSamOrBam($fileIn) == 1)}',
                        bam => "\n\t\t".'case ($fileIn =~ m/bam$/i){$validation = 1 if (checkFormat::checkFormatSamOrBam($fileIn) == 2)}',
                        vcf => "\n\t\t".'case ($fileIn =~ m/vcf|vcf\.gz$/i){$validation = 1 if (checkFormat::checkFormatVcf($fileIn) == 1)}',
                        gff => "\n\t\t".'case ($fileIn =~ m/gff$/i){$validation = 1 if (checkFormat::checkFormatGff($fileIn) == 1)}',
                        bed => "\n\t\t".'case ($fileIn =~ m/bed$/i){$validation = 1 if (checkFormat::checkFormatBed($fileIn) == 1)}'
                        #'phylip'=>"\n\t\t".'case ($fileIn =~ m/phy|phylip$/i){$validation = 1 if (checkFormat::checkFormatPhylip($fileIn) == 1)}'
                        # gtf
                        # nwk, newik, nk
                        # bcf
                        # ped
                        # intervals
                        # txt
                        # sai
                       );

#Format case addition
my @listIn = split/,/,$in;
foreach my $format (@listIn)
{
    $subText.= $formatValidator{$format};
}
#finishing the infos
$subText .= "\n\t\telse {toolbox::exportLog(\"ERROR: $module::$function : The file \$file is not a $in file\\n\",0);}\n\t};\n\tdie (toolbox::exportLog(\"ERROR: $module::$function : The file \$file is not a $in file\\n\",0) if \$validation == 0;";

#Extract options

$subText .= "\t#Picking up options\n\t".'my $options="";'."\n";
$subText .= "\t".'$options = toolbox::extractOptions($optionsHachees) if $optionsHachees;'."\n\n";

#Generating command
$subText .= "\t#Execute command\n";
$commandLine =~ s/FILEIN/\$fileIn/;
$commandLine =~ s/FILEOUT/\$fileOut/;
$commandLine =~ s/\[options\]/\$options/;
$subText .= "\tmy \$command = \"\$$commandLine\" ;";

#Executing command and return
$subText .= "\n\treturn 1 if (toolbox::run(\$command));\n";
$subText .= "\ttoolbox::exportLog(\"ERROR: $module::$function : ABORTED\\n\",0);\n}";


#Print in module
my $sedCom = "sed -i 's/^1;\$//' $toggle/modules/$moduleFile";
system("$sedCom") and die ("\nCannot remove the previous 1;:\n$!\n");

open (my $fhModule, ">>", "$toggle/modules/$moduleFile") or die ("\nCannot open for writing the file $moduleFile:\n$!\n");
print $fhModule $subText;
print $fhModule "\n\n1;\n";
close $fhModule;

#localConfig

#check if the software name already exists
$grep ="";
$grepCom = "grep -c \"$module\" $toggle/modules/localConfig.pm 2>/dev/null";
$grep = `$grepCom`;
chomp $grep;
if ($grep)
{   #the function exists...
    warn "\nThe function already exists in localConfig.pm\n";
}
else
{
    #the function is not registered
    
    #adding the soft name in the export
    my $sedCom = "sed -i 's/^our \@EXPORT=qw(/our \@EXPORT=qw(\$$module /' $toggle/modules/localConfig.pm";
    system("$sedCom") and die ("\nCannot add the software in the \@EXPORT:\n$!\n");
    
    #adding the path at the end of the file
    $sedCom = "sed -i 's/^1;\$//' $toggle/modules/localConfig.pm";
    system("$sedCom") and die ("\nCannot remove the previous 1;:\n$!\n");

    my $localLine = "#Path to $module\nour \$$module=\"/path/to/$module\";\n\n";
    open (my $fhLocal, ">>", "$toggle/modules/localConfig.pm") or die ("\nCannot open for writing the file localConfig.pm:\n$!\n");
    print $fhLocal $localLine;
    print $fhLocal "\n1;\n";
    close $fhLocal;
}

#function name
$grep ="";
$grepCom = "grep -c \"$function\" $toggle/modules/softwareManagement.pm 2>/dev/null";
$grep = `$grepCom`;
chomp $grep;
if ($grep)
{   #the function exists...
    warn "\nThe function already exists in softwareManagement.pm\n";
}
else
{
    #the function is not registered
    
    #adding the soft correct name
    #my $sedCom = "sed -i 's/^#NEW SOFT ADDED AUTOMATICALLY/#NEW SOFT ADDED AUTOMATICALLY";
    open (my $fhTmp, ">", "/tmp/tempModule.pm") or die ("\nCannot open for writing the temp file /tmp/tempModule.pm:\n$!\n");
    open (my $fhRead "<", "$toggle/modules/softwareManagement.pm") or die ("\nCannot open for reading the module softwaremanagement:\n$!\n");
    
    print $fhLocal $localLine;
    print $fhLocal "\n1;\n";
    close $fhLocal;
}
#NEW SOFT ADDED AUTOMATICALLY

#Input/output

#versionSoft

#BLOCK CREATION




print "Finished...\n\n Please have a look to the following files to check if everything is Ok:\n\n
    - $moduleFile
    - localConfig.pm
    - \n";

exit;