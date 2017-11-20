package abyss;

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
use localConfig;
use toolbox;
use checkFormat;
use Data::Dumper;


sub transabyss
{
    my($outputDir,$readGroup,$firstListOfFastq,$secondListOfFastq,$optionsHachees)=@_;
    ## if paired reads give $single as --left and $paired as --right; else give only $single
    my $orderedList=""; 
    my $command="";
    my $options="";

    if ($optionsHachees)
    {
         $options=toolbox::extractOptions($optionsHachees); ##Get given options
    }

    if ($options !~ m/--outdir\s\w+|--name\s\w+/) # The type of walker is not informed in the options
    {
        $options .= "--outdir ".$outputDir." --name ".$readGroup;
    }
    else
    {
        toolbox::exportLog("ERROR: abyss::transAbyss : You do not need to specify name or outdir options\n",2);
    }
    
    if (scalar (@{$secondListOfFastq}) > 0) # if is not empty,we have paired reads
    {
        if ((scalar (@{$firstListOfFastq}) > 0 ) and (scalar (@{$firstListOfFastq}) == scalar (@{$secondListOfFastq})) )  # if is not empty and same length
        {
            for (my $i=0; $i < scalar(@{$firstListOfFastq}); $i++)       # for each pair of Fastq file(s)
            {
                if (@{$firstListOfFastq}[$i] ne "NA" and checkFomat::checkFormatFastq(@{$firstListOfFastq}[$i])==1 )
                { ##Check if entry file exist and is not empty
                    if (@{$secondListOfFastq}[$i] ne "NA" and checkFomat::checkFormatFastq(@{$secondListOfFastq}[$i])==1 )
                    { ##Check if entry file exist and is not empty
                        $orderedList .= " --pe ".@{$firstListOfFastq}[$i]." ".@{$secondListOfFastq}[$i];    
                        
                    }
                    else
                    {
                        toolbox::exportLog("ERROR: abyss::transAbyss : The file ".@{$secondListOfFastq}[$i]." is uncorrect or is not a Fastq\n",0);
                        return 0;#File not Ok
                    }
                }
                else
                {
                    toolbox::exportLog("ERROR: abyss::transAbyss : The file ".@{$firstListOfFastq}[$i]." is uncorrect or is not a Fastq\n",0);
                    return 0;#File not Ok
                }
            }   
            #print @{$firstListOfFastq},"\n";
        }
        else
        {
            toolbox::exportLog("ERROR: abyss::transAbyss : Incorrect list of fastq files $firstListOfFastq \n",0);
            return 0;
        }
    }
    else  # Single mode
    {
        if (scalar (@{$firstListOfFastq}) > 0)  # if is not empty
        {
            $orderedList .= "--se ";
            foreach my $file (@{$firstListOfFastq})       # for each Fastq file(s)
            {                 
                if ($file ne "NA" and toolbox::checkFormatFastq($file)==1 )
                { ##Check if entry file exist and is not empty
                    $orderedList .= $file." ";
                }
                else
                {
                    toolbox::exportLog("ERROR: transabyss::transabyssRun : The file $file is uncorrect or is not a Fastq\n",0);
                    return 0;#File not Ok
                }
            }
        }
        else
        {
            toolbox::exportLog("ERROR: transabyss::transabyssRun : Incorrect list of fastq files $firstListOfFastq \n",0);
            return 0;
        }
    }
           
    $command=$transAbyss." ".$orderedList." ".$options;

    #DEBUG toolbox::exportLog("RUN: transabyss::transabyssRun : CMD:: $command\n",1);
    
    #Execute command
    if(toolbox::run($command)==1)
    {
         #my $moveCmd='mv '.$outputDir.'/*Trinity.fasta '.$outputDir.$readGroup; #rename the output file
         #chdir "$outputDir";
         ##rename the output files
         #my $moveCmd="ls | sed -rn \"s/(.*)\$/mv '&' '".$readGroup."_\\1'/ p\" | sh"; 
         #toolbox::run($moveCmd,"noprint");
         ##remove the sub-repositories to avoid errors during copy in the finalResults repository.     
         #my $rmCmd='find . -maxdepth 1 -mindepth 1 -type d -exec rm -r {} \;';
         #toolbox::run($rmCmd,"noprint");
         ## come back to the working directory.
         #chdir "../";
         
         return 1;#Command Ok
    }
    else
    {
         toolbox::exportLog("ERROR: abyss::transAbyss: Uncorrectly done\n",0);
         return 0;#Command not Ok
    }
}
     
1;

=head1 NAME

    Package I<abyss> 

=head1 SYNOPSIS

    use abyss;
	
	abyss::transAbyss($folderIn,tmpRoot);
	
	abyss::abyss($localFolder,$folderIn);
    
        
=head1 DESCRIPTION

    this module allows to run Abyss and Trans-Abyss
    
=head2 FUNCTIONS

=head3 abyss::transAbyss($folderIn,tmpRoot)

	Transcriptome assembly
	
=head3  abyss::abyss($localFolder,$folderIn)

	Genome assembly


=head1 AUTHORS

Intellectual property belongs to IRD, CIRAD and South Green developpement plateform for all versions also for ADNid for v2 and v3 and INRA for v3
Written by Christine Tranchant, Cecile Monat, Laura Helou, Abdoulaye Diallo, Julie Orjuela-Bouniol, Sebastien Ravel, Gautier Sarah, and Francois Sabot

=head1 SEE ALSO

L<http://toggle.southgreen.fr/>

=cut