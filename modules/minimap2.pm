package minimap2;

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


# TODO : do we want to support index ?
sub minimap2Index
{
#The standard way to write variables are:
#REFERENCE = $reference#PLEASE CHECK IF IT IS OK AT THIS POINT!!
	my ($fileIn,$fileOut,$reference,$optionsHachees) = @_;
	my $validation = 0;
	switch (1)
	{
		case ($fileIn =~ m/fasta|fa|fasta\.gz|fa\.gz$/i){$validation = 1 if (checkFormat::checkFormatFasta($fileIn) == 1)}
		else {toolbox::exportLog("ERROR: minimap2::minimap2Index : The file $fileIn is not a fasta file\n",0);}
	};
	die (toolbox::exportLog("ERROR: minimap2::minimap2Index : The file $fileIn is not a fasta file\n",0)) if $validation == 0;	#Picking up options
	my $options="";
	$options = toolbox::extractOptions($optionsHachees) if $optionsHachees;

	#Execute command
	my $command = "$minimap2 $options -d $fileOut $reference" ;
	return 1 if (toolbox::run($command));
	toolbox::exportLog("ERROR: minimap2::minimap2Index : ABORTED\n",0);
}

# Standard (not paired end) minimap2 mapping. SAM or PAF output
sub minimap2Map
{
#The standard way to write variables are:
#REFERENCE = $reference#PLEASE CHECK IF IT IS OK AT THIS POINT!!
	my ($fileIn,$fileOut,$reference,$optionsHachees) = @_;
	my $validation = 0;
	switch (1)
	{
		case ($fileIn =~ m/fasta|fa|fasta\.gz|fa\.gz$/i){$validation = 1 if (checkFormat::checkFormatFasta($fileIn) == 1)}
		case ($fileIn =~ m/fastq|fq|fastq\.gz|fq\.gz$/i){$validation = 1 if (checkFormat::checkFormatFastq($fileIn) == 1)}
		else {toolbox::exportLog("ERROR: minimap2::minimap2Map : The file $fileIn is not a fastq,fasta file\n",0);}
	};
	die (toolbox::exportLog("ERROR: minimap2::minimap2Map : The file $fileIn is not a valid fatsq,fasta file\n",0)) if $validation == 0;	#Picking up options
	my $options="";
	$options = toolbox::extractOptions($optionsHachees) if $optionsHachees;

	# Set a default preset if it has not been set by the user
	if ($options !~ m/-x|-ax/)
	{
		$options = "-x map-ont " . $options;
	}

	# Check that the -a is not set if output is paf or add it if the output is sam
	if ($fileOut =~ m/.paf$/i && $options =~ m/-a/)
	{
		toolbox::exportLog("ERROR: minimap2::minimap2Map : .paf output was requested but the -a option (sam output) is present. If you want paf output : Remove the -a option. If you want sam output : use minimap2Map instead", 0);
	}

	# If we want sam output, add -a if it's not set
	if ($fileOut =~ m/.sam$/i && $options !~ m/-a/)
	{
		$options .= " -a";
	}

	#Execute command
	my $command = "$minimap2 $options $reference $fileIn > $fileOut" ;
	return 1 if (toolbox::run($command));
	toolbox::exportLog("ERROR: minimap2::minimap2 : ABORTED\n",0);
}


# Paired end short read mapping. Sam or paf output.
sub minimap2MapPaired
{
	my ($fileIn1,$fileIn2,$fileOut,$reference,$optionsHachees) = @_;
	my $validation = 0;
	# Check both input files for validity
	foreach my $fileIn ($fileIn1, $fileIn2)
	{
		switch (1)
		{
			case ($fileIn =~ m/fasta|fa|fasta\.gz|fa\.gz$/i){$validation = 1 if (checkFormat::checkFormatFasta($fileIn) == 1)}
			case ($fileIn =~ m/fastq|fq|fastq\.gz|fq\.gz$/i){$validation = 1 if (checkFormat::checkFormatFastq($fileIn) == 1)}
			else {toolbox::exportLog("ERROR: minimap2::minimap2MapPaired : The file $fileIn is not a fastq,fasta file\n",0);}
		};
		die (toolbox::exportLog("ERROR: minimap2::minimap2MapPaired : The file $fileIn is not a valid fatsq,fasta file\n",0)) if $validation == 0;
	}

	# Format options for command line
	my $options="";
	$options = toolbox::extractOptions($optionsHachees) if $optionsHachees;

	# Check if the user has set any preset
	if ($options =~ m/-x|-ax/)
	{
		# We only allow the -x sr preset here; error if it's another one
		toolbox::exportLog("ERROR: minimap2::minimap2MapPaired: The only supported preset for paired end mapping is -x sr. Remove the -x option from your configuration file", 0) if ($options !~ m/-x sr|-ax sr/);
	} else {
		# The user has not chosen a preset, apply the correct one silently
		$options = "-x sr " . $options;
	}

	# Check that the -a is not set if output is paf or add it if the output is sam
	if ($fileOut =~ m/.paf$/i && $options =~ m/-a/)
	{
		toolbox::exportLog("ERROR: minimap2::minimap2MapPaired : .paf output was requested but the -a option (sam output) is present. If you want paf output : Remove the -a option. If you want sam output : use minimap2MapPaired instead", 0);
	}

	# If we want sam output, add -a if it's not set
	if ($fileOut =~ m/.sam$/i && $options !~ m/-a/)
	{
		$options .= " -a";
	}

	#Execute command
	my $command = "$minimap2 $options $reference $fileIn1 $fileIn2 > $fileOut" ;
	return 1 if (toolbox::run($command));
	toolbox::exportLog("ERROR: minimap2::minimap2 : ABORTED\n",0);
}

1;
