#!/usr/bin/perl

###################################################################################################################################
#
# Copyright 2014-2017 IRD-CIRAD-INRA-ADNid
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

#Will test if breakdancer works correctly
use strict;
use warnings;
use Test::More 'no_plan'; #Number of tests, to modify if new tests implemented. Can be changed as 'no_plan' instead of tests=>11 .
use Test::Deep;
use Data::Dumper;
use lib qw(../../modules/);


########################################
#use of bwa module ok
########################################
use_ok('localConfig') or exit;
use_ok('breakDancer') or exit;
can_ok('breakDancer','bam2cfg');
can_ok('breakDancer','breakDancer');

use localConfig;
use breakDancer;

my $bankData="$toggle/data/Bank/";
my $bamData="$toggle/data/testData/samBam/samBamSV/pindelBam.bam";

#########################################
#Remove files and directory created by previous test
#########################################
my $testingDir="$toggle/dataTest/breakDancerTestDir";
my $creatingDirCom="rm -Rf $testingDir ; mkdir -p $testingDir";                                    #Allows to have a working directory for the tests
system($creatingDirCom) and die ("ERROR: $0 : Cannot execute the command $creatingDirCom\n$!\n");

chdir $testingDir or die ("ERROR: $0 : Cannot go into the new directory with the command \"chdir $testingDir\"\n$!\n");


#######################################
#Creating the IndividuSoft.txt file
#######################################
my $creatingCommand="echo \"breakDancer\nTEST\" > individuSoft.txt";
system($creatingCommand) and die ("ERROR: $0: Cannot create the individuSoft.txt file with the command $creatingCommand \n$!\n");


#######################################
#Cleaning the logs for the test
#######################################
my $cleaningCommand="rm -Rf breakDancer_TEST_log.*";
system($cleaningCommand) and die ("ERROR: $0: Cannot clean the previous log files for this test with the command $cleaningCommand \n$!\n");


##########################################
##### abyss::abyssSimple
##########################################


# input file
my @listOfBam=($bamData);

#output data
my $bamCfgFile = $testingDir."/breakDancer.cfg";

# execution test
my %optionsHachees = ();
my $optionsHachees = \%optionsHachees;

is(breakDancer::bam2cfg(\@listOfBam,$bamCfgFile,$optionsHachees),1,'breakDancer::bam2cfg - running');

# expected output test
#Check if files created
my @expectedOutput = ("breakDancer.cfg","breakDancer_TEST_log.e","breakDancer_TEST_log.o","individuSoft.txt");
my $observedOutput = `ls`;
my @observedOutput = split /\n/,$observedOutput;
is_deeply(\@observedOutput,\@expectedOutput,'breakDancer::bam2cfg - Filetree created');

# expected content test $fastaRefBWT
my $expectedMD5sum = "36e50717eb9a27f7c6bd3b5626a9a296";                                        # structure of the ref file for checking
my $observedMD5sum = `md5sum breakDancer.cfg`;                	                        # structure of the test file for checking
my @withoutName = split (" ", $observedMD5sum);                                                 # to separate the structure and the name of file
$observedMD5sum = $withoutName[0];  	                        # just to have the md5sum result
is($observedMD5sum, $expectedMD5sum, "breakDancer::bam2cfg - output content file");               # TEST IF THE STRUCTURE OF THE FILE OUT IS GOOD
exit;
