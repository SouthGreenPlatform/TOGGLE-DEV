package flye;

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

#Perl modules
use strict;
use warnings;
use Data::Dumper;
use Switch;

#TOGGLe modules
use localConfig;
use toolbox;
use checkFormat;

sub flye
{
#The standard way to write variables are:
#REFERENCE = $reference#PLEASE CHECK IF IT IS OK AT THIS POINT!!
	my ($fileIn,$fileOut,$optionsHachees,$type) = @_;
	my $validation = 0;
	switch (1)
	{
		case ($fileIn =~ m/fasta|fa|fasta\.gz|fa\.gz$/i){$validation = 1 if (checkFormat::checkFormatFasta($fileIn) == 1)}
		case ($fileIn =~ m/fastq|fq|fastq\.gz|fq\.gz$/i){$validation = 1 if (checkFormat::checkFormatFastq($fileIn) == 1)}
		else {toolbox::exportLog("ERROR: flye::flyeNanoRaw : The file $fileIn is not a fasta,fastq file\n",0);}
	};
	die (toolbox::exportLog("ERROR: flye::flyeNanoRaw : The file $fileIn is not a fasta,fastq file\n",0)) if $validation == 0;	#Picking up options
	my $options="";
	$options = toolbox::extractOptions($optionsHachees) if $optionsHachees;
	my $param="";
	if ($type eq "flyeNanoRaw"){$param='--nano-raw'}
	elsif ($type eq "flyeNanoPacbio"){$param='--pacbio-raw'}
	elsif ($type eq "flyeNanoPacbioCorr"){$param='--pacbio-corr'}
	elsif ($type eq "flyeNanoCorr"){$param='--nano-corr'}
	elsif ($type eq "flyeSubassemblies"){$param='--subassemblies'}
	else { toolbox::exportLog("ERROR: flye::flye : The parameter of flye $param is unknown\n",0) }
	
	#Execute command
	my $command = "$flye $param $fileIn --out-dir $fileOut $options" ; #fileOut has to be a repertory
	return 1 if (toolbox::run($command));
	toolbox::exportLog("ERROR: flye::flyeNanoRaw : ABORTED\n",0);
	
	my $fastaOut="$fileOut/scaffolds.fasta";
	return $fastaOut;
	
}

1;
