package fastqc;



###################################################################################################################################
#
# Copyright 2014 IRD-CIRAD
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
# Intellectual property belongs to IRD, CIRAD and South Green developpement plateform
# Written by Cecile Monat, Christine Tranchant, Ayite Kougbeadjo, Cedric Farcy, Mawusse Agbessi, Marilyne Summo, and Francois Sabot
#
###################################################################################################################################



use strict;
use warnings;
use Data::Dumper;

use localConfig;
use toolbox;


################################################################################################
# sub fastqc::execution => to run fastqc
################################################################################################
# arguments :
# 	- fileIn : the fastq file to analyze
#	- dirOut : the directory that contains all the files generated by fastqc
################################################################################################
# return boolean :
#	- 1 if fastqc has runned correctly
#	- else 0
################################################################################################
sub execution
{
	toolbox::exportLog("ERROR: fastqc::execution : should get at least two arguments\n",0) if (@_ < 2);
	my ($filein,$dirOut,$optionsHachees)=@_; 
	
	toolbox::exportLog("INFOS: fastqc::execution : running\n", 1);
	
	my $options="";
        if ($optionsHachees)
	{
            $options=toolbox::extractOptions($optionsHachees);		##Get given options
        }

	
    	my $cmd_line=$fastqc." ".$options." -o $dirOut $filein"; 
	
	 if(toolbox::run($cmd_line)==1)		## if the command has been excuted correctly, export the log
	{
            toolbox::exportLog("INFOS: fastqc::execution : correctly done\n",1);
            return 1;
        }
	else
	{
            toolbox::exportLog("ERROR: fastqc::execution : ABORTED\n",0);
        }
}
################################################################################################
# END sub fastqc::execution
################################################################################################





################################################################################################
# sub fastqc::parse => parse fastqc output file and return information in a hash
################################################################################################
# arguments :
#	- dirOut : the directory that contains all the files generated by fastqc
################################################################################################
# return a hash with the header information (Fastqc statistics)
################################################################################################
sub parse
{
	toolbox::exportLog("ERROR: fastqc::parse : should get exactly one argument\n",0) if (@_ != 1); ## Test nombre d'arguments attendu
	my ($dirOut)=@_; 	
	my %headerFastqc; 		#Hash retourne par la fonction
	my $fastqcFile;		# Fichier de sortie de fastqc
	my $listOfFiles = toolbox::readDir($dirOut);		# list of files/folder present in 1_FASTQC folder
	my @listOfFiles = @$listOfFiles;			# recovery of this folder/files
	for (my $i=0; $i<=$#listOfFiles; $i++)			# for each of them
	{
		if ($listOfFiles[$i]=~m/(.+_fastqc):/)		# if not a zip folder
		{
			my $rightPath = $1;
			$fastqcFile = $rightPath."/fastqc_data.txt";	# recovery of this info to construct the right path for fastqc::parse
		}
	}

	toolbox::exportLog("INFOS: fastqc::parse : running on the file $fastqcFile\n", 1);
	
	toolbox::existsFile($fastqcFile);
	
	#########################################
	#Exemple d'entete du fichier a parser
	# FastQC        0.10.1
	#>>Basic Statistics      pass
	#Measure        Value   
	#Filename        sample_1.fq     
	#File type       Conventional base calls 
	#Encoding        Illumina 1.5    
	#Total Sequences 750000  
	#Filtered Sequences      0       
	#Sequence length 36      
	#%GC     43      
	#>>END_MODULE
	#########################################
	
	open(FASTQC,"<", $fastqcFile) or toolbox::exportLog("ERROR: fastqc::parse : Cannot open the file $fastqcFile\n$!\n",0);
	while (<FASTQC>)
	{
		chomp $_;
		last if ($_ =~ m/END_MODULE/); #End of the header parsed
		next if ($_ =~ m/^#/ or $_ =~ m/^>>/); #We do not need these lines
		my @currentLine = split /\t/,$_; # We pick up the correct line we need
		$headerFastqc{$currentLine[0]} = $currentLine[1];	
	}
	return(\%headerFastqc);

}
################################################################################################
# END sub fastqc::parse 
################################################################################################

1;

=head1 NOM

package I<fastqc> 

=head1 SYNOPSIS

	use fastqc;

	fastqc::execution($fastqFile,$fastqcDir);
	
	fastqc::parse($fastqcDir);                                                               

=head1 DESCRIPTION

This module is a set of functions related to fastqc software,  L<http://www.bioinformatics.babraham.ac.uk/projects/fastqc/>


=head2 Functions


=head3 execution()

This function execute the fastqc software to analyze a fastq file and a directory (that contains the files generated by fastqc) is created.
2 arguments are required : the fastq filename and the directory name created.

Return 1 if fastqc has ran correctly else 0.

Example : 
C<fastqc::execution($fqFile,$fastqcDir);> 	

=head3 parse()

This function analyze files generated by fastqc and return a hash with fastqc statistics (encoding, sequence number, %gc).

One argument is required: the directory generated by fastqc execution

Example : 
C<my $statRef=fastqc::parse($fasqcDirOut)> 


=head1 AUTHORS

 Cecile Monat, Ayite Kougbeadjo, Marilyne Summo, Cedric Farcy, Mawusse Agbessi, Christine Tranchant and Francois Sabot

L<http://www.southgreen.fr/>

=cut
