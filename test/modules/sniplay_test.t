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

#Will test if the modue fastqc work correctly

use strict;
use warnings;

use Test::More  'no_plan';
use Test::Deep;
use Data::Dumper;
use lib qw(../../modules/);

use localConfig;

########################################
#use of fastqc module ok
########################################
use_ok('sniplay');
can_ok('sniplay','ped2fasta');

use sniplay;

#########################################
#Remove files and directory created by previous test
#########################################
my $testingDir="$toggle/dataTest/sniplayTestDir";
my $creatingDirCom="rm -Rf $testingDir ; mkdir -p $testingDir";                                    #Allows to have a working directory for the tests
system($creatingDirCom) and die ("ERROR: $0 : Cannot execute the command $creatingDirCom\n$!\n");

chdir $testingDir or die ("ERROR: $0 : Cannot go into the new directory with the command \"chdir $testingDir\"\n$!\n");


#######################################
#Cleaning the logs for the test
#######################################
my $cleaningCommand="rm -Rf sniplay_TEST_log.*";
system($cleaningCommand) and die ("ERROR: $0: Cannot clean the previous log files for this test with the command $cleaningCommand \n$!\n");



##########################################
#sniplay::ped2fasta test
##########################################

# input file
my $pedFile = "$toggle/data/testData/ped/test.ped";
my $fastaOut = "out.fas";

# execution test
is(sniplay::ped2fasta($pedFile,$fastaOut),1,'sniplay::ped2fasta');     


# expected output test
my $expectedOutput = 'out.fas';
my $observedOutput = `ls out.fas`;
chomp($observedOutput);
is($observedOutput,$expectedOutput,'sniplay::ped2fasta - output list'); 

# expected content test
my $observedContent=`grep -c '>' $observedOutput`;
my $validContent = ( $observedContent =~ m/2/);
is($validContent,1,'sniplay::ped2fasta - output content');
