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
## COMMON MODULE TEST HEADER
######################################################################################################################################

use strict;
use warnings;
use Data::Dumper;

use Test::More 'no_plan'; #Number of tests, to modify if new tests implemented. Can be changed as 'no_plan' instead of tests=>11 .
use Test::Deep;

# Load localConfig if primary test is successful
use_ok('localConfig') or exit;
use localConfig;


########################################
# Extract automatically tool name and sub name list
########################################
my ($toolName,$tmp) = split /_/ , $0;
my $subFile=$toggle."/modules/".$toolName.".pm";
my @sub = `grep "^sub" $subFile`or die ("ERROR: $0 : Cannot extract automatically sub name list by grep command \n$!\n");


########################################
#Automatically module test with use_ok and can_ok
########################################
use_ok($toolName) or exit;
eval "use $toolName";

foreach my $subName (@sub)
{
    chomp ($subName);
    $subName =~ s/sub //;
    can_ok($toolName,$subName);
}

#########################################
#Preparing test directory
#########################################
my $testDir="$toggle/dataTest/$toolName"."TestModule";
my $cmd="rm -Rf $testDir ; mkdir -p $testDir";
system($cmd) and die ("ERROR: $0 : Cannot execute the test directory $testDir ($toolName) with the following cmd $cmd\n$!\n");
chdir $testDir or die ("ERROR: $0 : Cannot go into the test directory $testDir ($toolName) with the chdir cmd \n$!\n");


#########################################
#Creating log file
#########################################
my $logFile=$toolName."_log.o";
my $errorFile=$toolName."_log.e";
system("touch $testDir/$logFile $testDir/$errorFile") and die "\nERROR: $0 : cannot create the log files $logFile and $errorFile: $!\nExiting...\n";

######################################################################################################################################
######################################################################################################################################

##########################################
### input output Options
##########################################

my %optionsHachees = ();                # Hash containing informations
my $optionsHachees = \%optionsHachees;   # Ref of the hash

##########################################
### Common files
##########################################
my $fastaRef="$toggle/data/Bank/referenceBAI3.fasta";
my $fastqReads="$toggle/data/testData/nanopore/BAI3/BAI3_3x.fastq.gz";

##########################################
##### minimap2::minimap2Map (SAM output)
##########################################
my $mapSamOutput="map.sam";

%optionsHachees = (
	"-a" => '',
	"-x" => "map-ont",
);
$optionsHachees = \%optionsHachees;
is(minimap2::minimap2Map($fastqReads, $mapSamOutput, $fastaRef, $optionsHachees), 1, 'minimap2::minimap2Map (SAM) - running');

my @expectedOutput = ($mapSamOutput, 'minimap2_log.e', 'minimap2_log.o');
@expectedOutput = sort @expectedOutput;
my $observedOutput = `ls`;
my @observedOutput = split /\n/,$observedOutput;
is_deeply(\@observedOutput,\@expectedOutput,'minimap2::minimap2Map (SAM) - File tree');

# NOTE : We can't hash the SAM because it contains the command, which contains the file paths
# TODO find an alternative (count lines ? use flagstat ?)
#my $expectedMD5Sum = "eefc1feadc8a6850b93779d2efd2c1f0";
#my $observedMD5Sum = `md5sum $mapSamOutput`;
#my @withoutName = split(" ", $observedMD5Sum);
#$observedMD5Sum = $withoutName[0];
#is($observedMD5Sum, $expectedMD5Sum, "minimap2::minimap2Map (SAM) - SAM file contents");

##########################################
##### minimap2::minimap2Map (PAF output)
##########################################
my $mapPafOutput="map.paf";

%optionsHachees = (
	"-x" => "map-ont",
);
$optionsHachees = \%optionsHachees;
is(minimap2::minimap2Map($fastqReads, $mapPafOutput, $fastaRef, $optionsHachees), 1, 'minimap2::minimap2Map (PAF) - running');

push(@expectedOutput, $mapPafOutput);
@expectedOutput = sort @expectedOutput;
$observedOutput = `ls`;
@observedOutput = split /\n/,$observedOutput;
is_deeply(\@observedOutput,\@expectedOutput,'minimap2::minimap2Map (PAF) - File tree');

my $expectedMD5Sum = "80c66fb8f84c5294a06467d698e5337a";
my $observedMD5Sum = `md5sum $mapPafOutput`;
my @withoutName = split(" ", $observedMD5Sum);
$observedMD5Sum = $withoutName[0];
is($observedMD5Sum, $expectedMD5Sum, "minimap2::minimap2Map (PAF) - PAF file contents");

# TODO test for overlap, sr
