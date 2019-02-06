package wtdbg2;

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




sub wtdbg2
{
#The standard way to write variables are:
#REFERENCE = $reference#PLEASE CHECK IF IT IS OK AT THIS POINT!!
	my ($fileIn,$fileOut,$optionsHachees) = @_;
	my $validation = 0;
	switch (1)
	{
		case ($fileIn =~ m/fasta|fa|fasta\.gz|fa\.gz$/i){$validation = 1 if (checkFormat::checkFormatFasta($fileIn) == 1)}
		case ($fileIn =~ m/fastq|fq|fastq\.gz|fq\.gz$/i){$validation = 1 if (checkFormat::checkFormatFastq($fileIn) == 1)}
		else {toolbox::exportLog("ERROR: wtdbg2::wtdbg2 : The file $fileIn is not a fasta,fastq file\n",0);}
	};
	die (toolbox::exportLog("ERROR: wtdbg2::wtdbg2 : The file $fileIn is not a fasta,fastq file\n",0)) if $validation == 0;	#Picking up options
	my $options="";
	$options = toolbox::extractOptions($optionsHachees) if $optionsHachees;
	
	#TODO check if options -t exists - see to adjust automatically
	$options .= "-t 1" unless $options =~ m/-t \d+/;
	toolbox::exportLog("WARNING: wtdbg2::wtdbg2 : we adjusted the threads number to one to avoid overload of the jobs",2) unless $options =~ m/-t \d+/;

	#Execute command
	my $command = "$wtdbg2 $options -i $fileIn -o $fileOut" ;
	return 1 if (toolbox::run($command));
	toolbox::exportLog("ERROR: wtdbg2::wtdbg2 : ABORTED\n",0);
}


sub wtpoa-cns
{
#The standard way to write variables are:
#REFERENCE = $reference#PLEASE CHECK IF IT IS OK AT THIS POINT!!
	my ($fileIn,$fileOut,$reference,$optionsHachees) = @_;
	my $validation = 0;
	switch (1)
	{
		case ($fileIn =~ m/sam$/i){$validation = 1 if (checkFormat::checkFormatSamOrBam($fileIn) == 1)}
		case ($fileIn =~ m/lay\.gz$/i){$validation = 1}
		else {toolbox::exportLog("ERROR: wtdbg2::wtpoa-cns : The file $fileIn is not a layout,sam file\n",0);}
	};
	die (toolbox::exportLog("ERROR: wtdbg2::wtpoa-cns : The file $fileIn is not a layout,sam file\n",0)) if $validation == 0;	#Picking up options
	my $options="";
	$options = toolbox::extractOptions($optionsHachees) if $optionsHachees;
	
	
	#Execute command
	my $command = "$wtpoaCns $options -i $fileIn -o $fileOut" ;
	#If the input file is a SAM file the reference is requested
	if ($fileIn =~ m/sam$/ && $options !~ m/ -d /)
	{
		if ($reference ne "NA")
		{
			$command .= " -d ".$reference;
		}
		else
		{
			toolbox::exportLog("ERROR: wtdbg2::wtpoa-cns : A SAM file is provided, thus wtpoa-cns requests a reference (either -d option in the software option or in the general command as the -r option\n",0)
		}
	}
	return 1 if (toolbox::run($command));
	toolbox::exportLog("ERROR: wtdbg2::wtpoa-cns : ABORTED\n",0);
}

1;
