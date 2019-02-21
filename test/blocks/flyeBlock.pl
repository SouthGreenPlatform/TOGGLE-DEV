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
use Test::More 'no_plan';
use Test::Deep;
use fileConfigurator;
use localConfig;
use Data::Dumper;

#####################
## PATH for data test
#####################


# input file
my $dataFastq = "$toggle/data/testData/nanopore/BAI3/";

print "\n\n#################################################\n";
print "#### TEST flye \n";
print "#################################################\n";

# Remove files and directory created by previous test
my $testingDir="$toggle/dataTest/flye-noSGE-Blocks";
my $cleaningCmd="rm -Rf $testingDir";
system ($cleaningCmd) and die ("ERROR: $0 : Cannot remove the previous test directory with the command $cleaningCmd \n$!\n");

#Creating config file for this test
my @listSoft = ("flye");
fileConfigurator::createFileConf(\@listSoft,"blockTestConfig.txt");

my $runCmd = "toggleGenerator.pl -c blockTestConfig.txt -d ".$dataFastq." -o ".$testingDir;
print "\n### Toggle running : $runCmd\n";
system("$runCmd") and die "#### ERROR : Can't run TOGGLE for flye";

# check final results

# expected output content
my $fastaOut="$testingDir/finalResults/scaffolds.fasta";
my $observedOutput = `ls $testingDir/finalResults`;
my @observedOutput = split /\n/,$observedOutput;
my @expectedOutput = ('00-assembly','10-consensus','20-repeat','21-trestle','30-contigger','40-polishing','assembly_graph.gfa','assembly_graph.gv','assembly_info.txt','flye.log','params.json',$fastaOut);
#my @expectedOutput = ('FILE.EXTENTION','FILE.EXTENTION');

is_deeply(\@observedOutput,\@expectedOutput,'toggleGenerator - Two FILES (no SGE) flye::flye file list ');

# expected output value TO DO
# expected content test
my $observedContent=`wc -l $fastaOut`;
my $validContent = ( $observedContent =~ m/13818/);
is($validContent,1,'flye::flye - output content assembly with Flye');

    