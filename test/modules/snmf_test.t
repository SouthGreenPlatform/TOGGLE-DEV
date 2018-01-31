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

#Will test if snmf module work correctly works correctly
use strict;
use warnings;

use Test::More 'no_plan'; #Number of tests, to modify if new tests implemented. Can be changed as 'no_plan' instead of tests=>11 .
use Test::Deep;
use Data::Dumper;
use lib qw(../../modules/);

use localConfig;

########################################
#use of samtools modules ok
########################################
use_ok('toolbox') or exit;
use_ok('snmf') or exit;

can_ok( 'snmf','vcf2geno');
can_ok( 'snmf','structure');

use snmf;



#########################################
#Remove files and directory created by previous test
#########################################
my $testingDir="$toggle/dataTest/snmfTestDir";
my $creatingDirCom="rm -Rf $testingDir ; mkdir -p $testingDir";                                    #Allows to have a working directory for the tests
system($creatingDirCom) and die ("ERROR: $0 : Cannot execute the command $creatingDirCom\n$!\n");

chdir $testingDir or die ("ERROR: $0 : Cannot go into the new directory with the command \"chdir $testingDir\"\n$!\n");


#######################################
#Creating the IndividuSoft.txt file
#######################################
my $creatingCommand="echo \"snmf\nTEST\" > individuSoft.txt";
system($creatingCommand) and die ("ERROR: $0: Cannot create the individuSoft.txt file with the command $creatingCommand \n$!\n");


#######################################
#Cleaning the logs for the test
#######################################
my $cleaningCommand="rm -Rf snmf_TEST_log.*";
system($cleaningCommand) and die ("ERROR: $0: Cannot clean the previous log files for this test with the command $cleaningCommand \n$!\n");


################################################################################################
##snmf
################################################################################################


my %optionsRef = ();
my $optionsHachees = \%optionsRef;

# input file
my $vcfFile = "$toggle/data/testData/vcf/testsnmf.vcf";
my $fileOut = "testsnmf";

#execution test
is(snmf::vcf2geno($vcfFile, $fileOut),1,'snmf::vcf2geno');

#snmf option
my %optionsHachees = (
                      "-K" => "5",
					  "-c" => ""
                      );

my $optionHachees = \%optionsHachees;

#execution test
is(snmf::structure($vcfFile, $fileOut,$optionHachees),1,'snmf::structure');


# expected output test
my $observedOutput = `ls $fileOut*.Q`;
my @observedOutput = split /\n/,$observedOutput;
my @expectedOutput = ("$fileOut.SNMFSTRUCTURE.2.Q","$fileOut.SNMFSTRUCTURE.3.Q","$fileOut.SNMFSTRUCTURE.4.Q","$fileOut.SNMFSTRUCTURE.5.Q");

is_deeply(\@observedOutput,\@expectedOutput,'snmf::structure - output list');


# expected content test
my $observedContent=`wc -l $fileOut.SNMFSTRUCTURE.5.Q`;
my $validContent = ( $observedContent =~ m/258/);
is($validContent,1,'snmf::structure - output content');




exit;
