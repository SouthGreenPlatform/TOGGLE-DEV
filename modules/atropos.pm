package atropos;

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

use strict;
use warnings;
use Data::Dumper;

use localConfig;
use toolbox;



################################################################################################
# sub atropos::exectution => to run cutdapt
################################################################################################
# arguments :
# 	- fileIn : the fastq file with the sequences to clean
#	- fileConf : the name of the atropos configuration file created by the sub
# atropos::createConfFile
#	- fileOut : the fastq file generated by atropos with the sequences cleaned
#   - $optionsatropos : hash generated from config file
################################################################################################
# No parameters returned, parameters will be returned and errors managed by toolbox::run
################################################################################################
sub execution
{
	my ($fileIn1,$fileOut1,$fileIn2, $fileOut2, $optionsHachees)=@_;	 # recovery of arguments
	my $cmd;
	my $singleMode=0;
	$singleMode=1 if (not (defined $fileIn2) and not (defined $fileOut2));# @ARGVnot defined $fileIn2 or not defined $fileOut2);

	## Lancement de atropos
	my $options=toolbox::extractOptions($optionsHachees, " ");		##Get given options
	if ($singleMode)
	{
		##DEBUG toolbox::exportLog("DEBUG: SINGLE MODE",2);
		$cmd="$atropos $options -o $fileOut1 -se $fileIn1";			# command line to execute atropos
	}
	else
	{
		#DEBUG toolbox::exportLog("DEBUG: PAIRED MODE",2);
		$cmd="$atropos $options -o $fileOut1 -p $fileOut2 -pe1 $fileIn1 -pe2 $fileIn2";			# command line to execute atropos
	}

	toolbox::run($cmd);									# tool to execute the command line
}
################################################################################################
# END sub atropos::execution => to run cutdapt
################################################################################################

1;


=head1 NAME

package I<atropos>

=head1 SYNOPSIS

	use atropos;

	atropos::execution($fasqFilename,$atroposFileConf,$fastqCleanedFile);

=head1 DESCRIPTION

This module is a set of functions related to atropos software, L<https://github.com/jdidion/atropos>


=head2 Functions

=head3 atropos::execution()

This function execute the atropos software and generate a cleaned sequences file (without adaptators and minimal size).

It is required 3 arguments in input :
- the sequence file (fastq format),
- the configuration file generated by the fonction atropos::createConfFile
- the name of file (fastq format) generated with the sequences cleaned
- the hash from config file with atropos options

Return 0,1,2 with the sub toolbox::run

Example:
C<atropos::execution ($fqFile,$atroposConf,$fastqatropos, $logFile, $hashOptions) ;>


=head1 AUTHORS

 Cecile Monat, Ayite Kougbeadjo, Marilyne Summo, Cedric Farcy, Mawusse Agbessi, Christine Tranchant and Francois Sabot

L<http://www.southgreen.fr/>

=cut
