package vcftools;

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
# sub vcftools::stats => to run stats
################################################################################################
# arguments :
# 	- VCFIn : the VCF file to analyze
#	- heterozygosity : the heterozygosity output file (mandatory)
################################################################################################
# return boolean :
#	- 1 if stats has runned correctly
#	- else 0
################################################################################################
sub stats
{
	my($vcfFileIn,$out,$optionsHachees)=@_;
	if (toolbox::sizeFile($vcfFileIn)==1)
	{ ##Check if entry file exist and is not empty
	
          #Check if the format is correct
          if (checkFormat::checkFormatVcf($vcfFileIn)==0)
          {#The file is not a VCF file
               toolbox::exportLog("ERROR: vcftools::stats : The file $vcfFileIn is not a VCF file\n",0);
               return 0;
          }
          

		  my $options="";
          
          if ($optionsHachees)
          {
               $options=toolbox::extractOptions($optionsHachees);
          }
          
          
          my $command=$vcftools." --min-alleles 2 --max-alleles 2 --vcf $vcfFileIn --out $out --het ".$options;
		  my $command2=$vcftools." --min-alleles 2 --max-alleles 2 --vcf $vcfFileIn --out $out --missing-indv ".$options;
		  my $command3=$vcftools." --min-alleles 2 --max-alleles 2 --vcf $vcfFileIn --out $out --TsTv-summary ".$options;
		  my $command4=$vcftools." --min-alleles 2 --max-alleles 2 --vcf $vcfFileIn --out $out --freq ".$options;
		  my $command5=$vcftools." --min-alleles 2 --max-alleles 2 --vcf $vcfFileIn --out $out --missing-site ".$options;
          
          #Execute command
          if(toolbox::run($command)==1 && toolbox::run($command2)==1 && toolbox::run($command3)==1 && toolbox::run($command4)==1 && toolbox::run($command5)==1)
          {
				############################################
				# reorganize output for heterozygosity
				############################################
				open(my $H,"$out.het");
				<$H>;
				open(my $H2,">$out.het.2");
				print $H2 "INDV\t% of heterozygous sites\n";
				while(<$H>){
						my ($indv,$hom,$nsites) = (split(/\t/,$_))[0,1,3];
						my $het = (($nsites-$hom)/$nsites)*100;
						print $H2 "$indv\t$het\n";
				}
				close($H);
				close($H2);
				
				system("head -1 $out.het.2 >$out.het");
				system("grep -v 'heterozygous' $out.het.2 | sort -n -k 2 >>$out.het");
				
				##################################################
				# MAF
				##################################################
				my %counts;
				open(my $FREQ,"$out.frq");
				<$FREQ>;
				while(<$FREQ>){
						my $line = $_;
						$line =~s/\n//g;
						$line =~s/\r//g;
						my @inf = split(/\t/,$line);
						my ($base,$freq) = split(":",$inf[5]);
						my $arrondi = sprintf("%.2f",$freq);
						$counts{$arrondi}++;

				}
				close($FREQ);
				open(my $OUT2,">$out.freq");
				print $OUT2 "Values     nb of values\n";
				for (my $i = 0; $i <= 0.5; $i=$i+0.01)
				{
						my $arrondi = sprintf("%.2f",$i);
						my $nb = 0;
						if ($counts{$arrondi})
						{
								$nb = $counts{$arrondi};
						}
						print $OUT2 "$i $nb\n";
				}
				close($OUT2);
				
				############################################
				# reorganize output for missing data
				############################################

				my %counts2;
				open(my $MISS,"$out.lmiss");
				<$MISS>;
				while(<$MISS>){
						my $line = $_;
						$line =~s/\n//g;
						$line =~s/\r//g;
						my @inf = split(/\t/,$line);
						my $freq = $inf[5];
						my $arrondi = sprintf("%.2f",$freq);
						$counts2{$arrondi}++;

				}
				close($MISS);
				open(my $M2,">$out.miss_distrib");
				print $M2 "Values       nb of values\n";
				for (my $i = 0; $i <= 0.5; $i=$i+0.01)
				{
						my $arrondi = sprintf("%.2f",$i);
						my $nb = 0;
						if ($counts2{$arrondi})
						{
								$nb = $counts2{$arrondi};
						}
						print $M2 "$i   $nb\n";
				}
				close($M2);


				system("head -1 $out.imiss >$out.miss.2");
				system("grep -v 'GENOTYPES_FILTERED' $out.imiss | sort -n -k 5 >>$out.miss");
		  
               return 1;#Command Ok
          }
          else
          {
               toolbox::exportLog("ERROR: vcftools::stats : Uncorrectly done\n",0);
               return 0;#Command not Ok
          }
     }
     else
     {
        toolbox::exportLog("ERROR: vcftools::stats : The file $vcfFileIn is uncorrect\n",0);
        return 0;#File not Ok
     }
}

################################################################################################
## END sub vcftools::stats
#################################################################################################


1;

=head1 NOM

package I<vcftools> 

=head1 SYNOPSIS

	use vcftools;

	vcftools::stats($vcf,$heterozygosity);                                                           

=head1 DESCRIPTION

This module is a set of functions related to vcftools software,  L<http://vcftools.sourceforge.net/>


=head2 Functions


=head3 stats()

This function allows to generate some statistics about VCF (heterozygosity, missing data...).
2 arguments are required : the VCF filename and the heterozygosity file created.

Return 1 if stats has ran correctly else 0.

Example : 
C<vcftools::stats($vcfFile,$heterozygosity);> 	

=head1 AUTHORS

 Cecile Monat, Ayite Kougbeadjo, Marilyne Summo, Cedric Farcy, Mawusse Agbessi, Christine Tranchant, Alexis Dereeper and Francois Sabot

L<http://www.southgreen.fr/>

=cut
