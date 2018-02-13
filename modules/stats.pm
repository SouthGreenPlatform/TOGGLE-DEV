package stats;

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
use localConfig;
use toolbox;
use Data::Dumper;
use checkFormat;

use picardTools;
use samTools;

##############################################
##stats
##Module containing basic stats functions
##used to write reports
##############################################
##
##
## mappingStat
# blablablabla
sub mapping
{
     # Getting arguments
     my($bamFileIn,$bamFileOut)=@_;
     
     my $softParameters;
     $softParameters->{"CREATE_INDEX"}="TRUE";
     $softParameters->{"SORT_ORDER"}="coordinate";
     $softParameters->{"VALIDATION_STRINGENCY"}="SILENT";     
        
     # Check if the sam or bam file exists and is not empty
     if (toolbox::sizeFile($bamFileIn)==1)
     {     
          #Check if the format is not correct neither sam or ban
          if (checkFormat::checkFormatSamOrBam($bamFileIn)==0)
          {
               #The file is not a BAM/SAM file
               toolbox::exportLog("ERROR: stats::mappingStat : The file $bamFileIn is not a SAM/BAM file\n",0);
               return 0;
          }

          # Automatic sorting sam/bam file, indexing it and generating a bam if sam file          
          picardTools::picardToolsSortSam($bamFileIn,$bamFileOut,$softParameters);
     
          # flagstat
          my $flagstatsOutputFile=$bamFileOut;
          $flagstatsOutputFile =~ s/\.bam$/\.flagstat\.mapping\.stat/;
          samTools::samToolsFlagstat($bamFileOut,$flagstatsOutputFile);
          
          # idxstats
          my $idxstatsOutputFile=$bamFileOut;
          $idxstatsOutputFile =~ s/\.bam$/\.idxstats\.mapping\.stat/;
          samTools::samToolsIdxstats($bamFileOut,$idxstatsOutputFile);

          # Delete bam generated
          my $rmCommand = "rm $bamFileOut*";
          toolbox::run($rmCommand,"noprint");
          
          # Delete bai generated
          $bamFileOut =~ s/\.bam$/\.bai/;
          $rmCommand = "rm $bamFileOut*";
          toolbox::run($rmCommand,"noprint");
     }
     else
     {
        toolbox::exportLog("ERROR: stats::mappingStat : The file $bamFileIn is uncorrect\n",0);
        return 0;#File not Ok
     }
}

sub generateStats
{

    my ($statDir)=@_;		# get parameters
	my $fileList = toolbox::readDir($statDir);		# get stat files list
	
	my ($texRaw, $texAssembly, $texMapping, $bool);	# different sections of tex stat file
	$bool=0;
	
	#$texMapping = "\\subsection{Mapping}
	#\\begin{table}[ht]
	#	\\centering
#		\\begin{tabular}{l|r|r|r}
#			Samples & Raw sequences & Mapped sequences & Properly mapped  \\\\\\hline
#			toto---tata & 001 & Normal \\\\
#		\\end{tabular}
#\\end{table}" ;

	my $statTexFile = "stats.tex";
	open(my $texFh, ">", $statTexFile) or toolbox::exportLog("$0 : open error of $statTexFile .... $!\n",0);
	## DEBUG toolbox::exportLog("J ouvre $statTexFile ", 1);
	# Parsing stat files
     
    foreach my $file (@{$fileList}) #Copying the final data in the final directory
	{
		toolbox::exportLog("Je lis 1 $file", 1);
		#my ($basicName)=toolbox::extractPath($file);
		if ($file =~ /\.flagstat.mapping.stat$/)
		{
			$bool=1;
			open (my $fh, "<", $file) or toolbox::exportLog("$0 : open error of $file .... $!\n",0);
			my ($raw, $mapped, $properly);
			$raw = $mapped = $properly = 0;
               
               ##DEBUG q toolbox::exportLog("Je lis $file", 1);
			while (my $line = <$fh>)
			{
				if ($line =~ /^(\d+)\s+.+in\stotal/) { $raw = $1; 	toolbox::exportLog("Je lis $line - $1 -", 1);}
				elsif ($line =~ /^(\d+)\s+.+in\sproperly\spaired/) { $properly = $1; }
				elsif ($line =~ /^(\d+)\s+.+in\smapped\s\(/) { $mapped = $1; }
			}

			$texMapping .= " & $raw & $mapped $ $properly ";
			
			close $fh;
			
		}
	}
	
#	$texMapping .= "\\end{tabular}
#\\end{table}";
	
	print $texFh $texMapping;
	close $texFh;
	
	toolbox::exportLog($texMapping,1);

}


1;

=head1 NAME

    Package I<stats> 

=head1 SYNOPSIS

    This package contains the whole modules for the ...

=head1 DESCRIPTION

   ....

=head2 Functions

=over 4

=item mergeHeader (Merges the headers from various sources in a single one)


=back

=head1 AUTHORS

Intellectual property belongs to IRD, CIRAD and South Green developpement plateform 
Written by Cecile Monat, Ayite Kougbeadjo, Marilyne Summo, Cedric Farcy, Mawusse Agbessi, Christine Tranchant and Francois Sabot

=head1 SEE ALSO

L<http://www.southgreen.fr/>		# SOUTH GREEN

=cut
