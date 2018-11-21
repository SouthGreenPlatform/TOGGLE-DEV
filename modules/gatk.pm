package gatk;

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

# GATK Base Recalibrator: recalibrate the quality score of bases from informations stemming from SNP VCF file
sub gatkBaseRecalibrator
{
    my ($refFastaFileIn, $bamToRecalibrate, $tableReport, $optionsHachees) = @_;      # recovery of information
    if ((checkFormat::checkFormatSamOrBam($bamToRecalibrate)==2) and (toolbox::sizeFile($refFastaFileIn)==1) and (toolbox::sizeFile($bamToRecalibrate)==1))     # check if files exists and arn't empty and stop else
    {
        my $options=toolbox::extractOptions($optionsHachees);       # extraction of options parameters
        #print $options,"\n";
        if ($options !~ m/-T/) # The type of walker is not informed in the options
        {
            $options .= " -T BaseRecalibrator";
        }
    
        my $comGatkBaseRecalibrator = "$GATK"."$options"." -I $bamToRecalibrate -R $refFastaFileIn -o $tableReport";       # command line
        if(toolbox::run($comGatkBaseRecalibrator)==1)
        {
            return 1;
        }
        else        # if one or some previous files doesn't exist or is/are empty or if gatkBaseRecalibrator failed
        {
            toolbox::exportLog("ERROR: gatk::gatkBaseRecalibrator : Uncorrectly done\n", 0);        # returns the error message
        }
    }
    else        # if one or some previous files doesn't exist or is/are empty or if gatkBaseRecalibrator failed
    {
        toolbox::exportLog("ERROR: gatk::gatkBaseRecalibrator : The files $refFastaFileIn or/and $bamToRecalibrate are incorrects\n", 0);     # returns the error message
    }
}  

sub gatkPrintReads
{
    my ($refFastaFileIn, $bamToRecalibrate, $bamOut, $tableReport, $optionsHachees) = @_;      # recovery of information
    if ((checkFormat::checkFormatSamOrBam($bamToRecalibrate)==2) and (toolbox::sizeFile($refFastaFileIn)==1) and (toolbox::sizeFile($bamToRecalibrate)==1))     # check if files exists and arn't empty and stop else
    {
        my $options=toolbox::extractOptions($optionsHachees);       # extraction of options parameters
        if ($options !~ m/-T/) # The type of walker is not informed in the options
        {
            $options .= " -T PrintReads";
        }
    
        my $comGatkPrintReads = "$GATK"."$options"." -I $bamToRecalibrate -R $refFastaFileIn -o $bamOut  ";       # command line
        
        if (defined $tableReport)
        {
            if (toolbox::sizeFile($tableReport)==1)
            {
                $comGatkPrintReads .= " -BQSR $tableReport";
            }
            else
            {
                   toolbox::exportLog("ERROR : $0 : gatkIndelRealigner: the Input covariates table file don't exist\n",1);
            }
        }
        
        if(toolbox::run($comGatkPrintReads)==1)
        {
            toolbox::exportLog("INFOS: gatk::gatkPrintReads : Correctly done\n",1);
            return 1;
        }
        else        # if one or some previous files doesn't exist or is/are empty or if gatkPrintReads failed
        {
            toolbox::exportLog("ERROR: gatk::gatkPrintReads : Uncorrectly done\n", 0);        # returns the error message
        }
    }
    else        # if one or some previous files doesn't exist or is/are empty or if gatkPrintReads failed
    {
        toolbox::exportLog("ERROR: gatk::gatkPrintReads : The files $refFastaFileIn or/and $bamToRecalibrate are incorrects\n", 0);     # returns the error message
    }    
    

}


# GATK Realigner Target Creator: determine (small) suspicious intervals which are likely in need of realignment
sub gatkRealignerTargetCreator
{
    my ($refFastaFileIn, $bamToRealigne, $intervalsFile, $optionsHachees) = @_;     # recovery of information
    if ((checkFormat::checkFormatSamOrBam($bamToRealigne)==2) and (toolbox::sizeFile($refFastaFileIn)==1) and (toolbox::sizeFile($bamToRealigne)==1))     # check if files exists and arn't empty and stop else
    {
        my $options=toolbox::extractOptions($optionsHachees);       # extraction of options parameters
        if ($options !~ m/-T/) # The type of walker is not informed in the options
        {
            $options .= " -T RealignerTargetCreator";
        }
        my $comGatkRealignerTargetCreator = "$GATK"."$options"." -R $refFastaFileIn -I $bamToRealigne -o $intervalsFile ";#--fix_misencoded_quality_scores -fixMisencodedQuals";        # command line
        if(toolbox::run($comGatkRealignerTargetCreator)==1)     # command line execution
        {
            return 1;
        }
    }
    else        # if one or some previous files doesn't exist or is/are empty or if gatkRealignerTargetCreator failed
    {
        toolbox::exportLog("ERROR: gatk::gatkRealignerTargetCreator : The files $refFastaFileIn or/and $bamToRealigne are incorrects\n", 0);        # returns the error message
    }
}
# GATK Indel Realigner: run the realigner over the intervals producted by gatk::gatkRealignerTargetCreator (see above)
sub gatkIndelRealigner
{
    my ($refFastaFileIn, $bamToRealigne, $intervalsFile, $bamRealigned, $optionsHachees) = @_;      # recovery of information
    if ((checkFormat::checkFormatSamOrBam($bamToRealigne)==2) and (toolbox::sizeFile($refFastaFileIn)==1) and (toolbox::sizeFile($bamToRealigne)==1) and (toolbox::readFile($intervalsFile)==1))      # check if files exists and arn't empty and stop else
    {
        my $options=toolbox::extractOptions($optionsHachees);       # extraction of options parameters
        if ($options !~ m/-T/) # The type of walker is not informed in the options
        {
            $options .= " -T IndelRealigner";
        }
        my $comGatkIndelRealigner = "$GATK"."$options"." -R $refFastaFileIn -I $bamToRealigne -targetIntervals $intervalsFile -o $bamRealigned";# --fix_misencoded_quality_scores -fixMisencodedQuals";     # command line
        if(toolbox::run($comGatkIndelRealigner)==1)
        {                                                                                                                                                                               # command line execution
            return 1;
        }
    }
    else        # if one or some previous files doesn't exist or is/are empty or if gatkIndelRealigner failed
    {
        toolbox::exportLog("ERROR: gatk:gatkIndelRealigner : The files $refFastaFileIn, $bamToRealigne or/and $intervalsFile are incorrects\n", 0);     # returns the error message
    }
}
# GATK Haplotype Caller: Haplotypes are evaluated using an affine gap penalty Pair HMM.
sub gatkHaplotypeCaller
{
    my ($refFastaFileIn, $vcfCalled, $listOfBam, $optionsHachees, $vcfSnpKnownFile, $intervalsFile) = @_;      # recovery of information
 
    #TODO adding VCF control
    if (toolbox::sizeFile($refFastaFileIn)==1)     # check if files exist and isn't empty and stop else
    {
        ## informations about SNP know file
        my $dbsnp="";
        if (($vcfSnpKnownFile) and (toolbox::sizeFile($vcfSnpKnownFile)==0))        # If specified, check if the file of known SNP is correct
        {
            toolbox::exportLog("ERROR: gatk::gatkHaplotypeCaller : The file $vcfSnpKnownFile is uncorrect\n", 0);       # returns the error message
        }
        elsif (($vcfSnpKnownFile) and (toolbox::sizeFile($vcfSnpKnownFile)==1))     # if specified and file correct ...
        {
            $dbsnp=" --dbsnp $vcfSnpKnownFile";     # ... recovery of informations for command line used later
        }
        
        ## informations about intervals file
        my $intervals="";
        if (($intervalsFile) and (toolbox::sizeFile($intervalsFile)==0))        # if specified, check if the file of intervals is correct
        {
            toolbox::exportLog("ERROR: gatk::gatkHaplotypeCaller : The file $intervalsFile is uncorrect\n", 0);     # returns the error message
        }
        elsif (($intervalsFile) and (toolbox::sizeFile($intervalsFile)==1))     # if specified and file of intervals is correct ...
        {
            $intervalsFile="-L $intervalsFile";     # ... recovery of informations for command line used later
        }
        
        my $bamFiles_names="";
        foreach my $file (@{$listOfBam})       # for each BAM file(s)
        {
            if (checkFormat::checkFormatSamOrBam($file)==2 and toolbox::sizeFile($file)==1)        # if current file is not empty
            {
                $bamFiles_names.="-I ".$file." ";       # recovery of informations fo command line used later
            }
            else        # if current file is empty
            {
                toolbox::exportLog("ERROR: gatk::gatkHaplotypeCaller : The file $file is uncorrect\n", 0);      # returns the error message
            }
        }
        
        my $options="";
        if ($optionsHachees)
        {
            $options=toolbox::extractOptions($optionsHachees);      ##Get given options
        }
        if ($options !~ m/-T/) # The type of walker is not informed in the options
        {
            $options .= " -T HaplotypeCaller";
        }
        my $comGatkHaplotypeCaller = "$GATK"."$options"." -R $refFastaFileIn $bamFiles_names $dbsnp $intervals -o $vcfCalled";      # command line
        if(toolbox::run($comGatkHaplotypeCaller)==1)        # command line execution
        {
            return 1;
        }
        else
        {
            toolbox::exportLog("ERROR: gatk::gatkHaplotypeCaller : Uncorrectly done\n", 0);     # returns the error message
        }
    }
    else        # if one or some previous files doesn't exist or is/are empty or if gatkHaplotypeCaller failed
    {
        toolbox::exportLog("ERROR: gatk::gatkHaplotypeCaller : The file $refFastaFileIn is uncorrect\n", 0);        # returns the error message
    }
}
# GATK Select Variants: Selects variants from a VCF source.
sub gatkSelectVariants
{
    my ($refFastaFileIn, $vcfSnpKnownFile, $vcfVariantsSelected, $optionsHachees) = @_;     # recovery of information    
    #TODO adding the VCF type control
    if ((toolbox::sizeFile($refFastaFileIn)==1)  and  (toolbox::sizeFile($vcfSnpKnownFile)==1))     # check if ref file exist and isn't empty and stop else
    {
        my $options=toolbox::extractOptions($optionsHachees);       # extraction of options parameters
        if ($options !~ m/-T/) # The type of walker is not informed in the options
        {
            $options .= " -T SelectVariants";
        }
        my $comGatkSelectVariants = "$GATK"."$options"." -R $refFastaFileIn --variant $vcfSnpKnownFile -o $vcfVariantsSelected";        # command line
        if(toolbox::run($comGatkSelectVariants)==1)     # command line execution
        {
            return 1;
        }
        else        # if one or some previous files doesn't exist or is/are empty or if gatkSelectVariants failed
        {
            toolbox::exportLog("ERROR: gatk::gatkSelectVariants : Uncorrectly done\n", 0);      # returns the error message
        }
    }
    else        # if one or some previous files doesn't exist or is/are empty or if gatkSelectVariants failed
    {
        toolbox::exportLog("ERROR: gatk::gatkSelectVariants : The files $refFastaFileIn or/and $vcfSnpKnownFile are incorrects\n", 0);      # returns the error message
    }
}



# GATK Variant Filtration: filter variant calls using a number of user-selectable, parameterizable criteria.
sub gatkVariantFiltration
{
    my ($refFastaFileIn, $vcfFiltered, $vcfToFilter, $optionsHachees) = @_;     # recovery of information
    #TODO adding the VCF type control
    if ((toolbox::sizeFile($refFastaFileIn)==1) and (toolbox::sizeFile($vcfToFilter)==1))       # check if ref file exist and isn't empty and stop else
    {
        my $options="";
        if ($optionsHachees)
        {
            $options=toolbox::extractOptions($optionsHachees);      ##Get given options
        }
        if ($options !~ m/-T/) # The type of walker is not informed in the options
        {
            $options .= " -T VariantFiltration";
        }
        ##DEBUG print Dumper($options);     # extraction of options parameters
        my $comGatkVariantFiltration = "$GATK"."$options"." -R $refFastaFileIn -o $vcfFiltered --variant $vcfToFilter";     # command line
        if(toolbox::run($comGatkVariantFiltration)==1)      # command line execution
        {
            return 1;
        }
        else        # if one or some previous files doesn't exist or is/are empty or if gatkVariantFiltration failed
        {
            toolbox::exportLog("ERROR: gatk::gatkVariantFiltration : Uncorrectly done\n", 0);       # returns the error message
        }
    }
    else        # if one or some previous files doesn't exist or is/are empty or if gatkVariantFiltration failed
    {
        toolbox::exportLog("ERROR: gatk::gatkVariantFiltration :  The files $refFastaFileIn or/and $vcfToFilter are incorrects\n", 0);      # returns the error message
    }
}




# GATK Unified Genotyper: A variant caller which unifies the approaches of several disparate callers -- Works for single-sample and multi-sample data.
sub gatkUnifiedGenotyper
{
    my ($refFastaFileIn, $listOfBam, $vcfFileOut, $optionsHachees) = @_;        # recovery of information  
    #TODO adding VCF type control
    my $bamFilesNames="";
    foreach my $file (@{$listOfBam})       # for each BAM file(s)
    {
        if (checkFormat::checkFormatSamOrBam($file)==2 and toolbox::sizeFile($file)==1)        # if current file is not empty and is a BAM
        {
            $bamFilesNames.="-I ".$file." ";       # recovery of informations fo command line used later
        }
        else        # if current file is empty or not a BAM
        {
            toolbox::exportLog("ERROR: gatk::gatkUnifiedGenotyper : The file $file is not a BAM and cannot be used\n", 0);      # returns the error message
        }
    }
    
    my $options=toolbox::extractOptions($optionsHachees);
    if ($options !~ m/-T/) # The type of walker is not informed in the options
    {
        $options .= " -T UnifiedGenotyper";
    }
    my $comGatkUnifiedGenotyper = "$GATK"."$options"." -R $refFastaFileIn $bamFilesNames -o $vcfFileOut";        # command line
    if(toolbox::run($comGatkUnifiedGenotyper)==1)       # command line execution
    {
        return 1;
    }
    else        # if one or some previous files doesn't exist or is/are empty or if gatkVariantFiltration failed
    {
        toolbox::exportLog("ERROR: gatk::gatkUnifiedGenotyper : Uncorrectly done\n", 0);        # returns the error message
    }
    
}
# GATK Read backedPhasing: Walks along all variant ROD loci, caching a user-defined window of VariantContext sites, and then finishes phasing them when they go out of range (using upstream and downstream reads).
sub gatkReadBackedPhasing
{
    my ($refFastaFileIn, $bamFileIn,$vcfVariant, $vcfFileOut, $optionsHachees) = @_;         # recovery of information
    #TODO adding VCF type control
    if ((checkFormat::checkFormatSamOrBam($bamFileIn)==2) and (toolbox::sizeFile($refFastaFileIn)==1) and (toolbox::sizeFile($bamFileIn)==1) and (toolbox::sizeFile($vcfVariant)==1))     # check if ref file exist and isn't empty and stop else
    {
        my $options=toolbox::extractOptions($optionsHachees);
        if ($options !~ m/-T/) # The type of walker is not informed in the options
        {
            $options .= " -T ReadBackedPhasing";
        }
        my $comGatkReadBackedPhasing = "$GATK"."$options"." -R $refFastaFileIn -I $bamFileIn --variant $vcfVariant -o $vcfFileOut";     # command line
        if(toolbox::run($comGatkReadBackedPhasing)==1)      # command line execution
        {
            return 1;
        }
    }
    else        # if one or some previous files doesn't exist or is/are empty or if gatkVariantFiltration failed
    {
        toolbox::exportLog("ERROR: gatk::gatkReadBackedPhasing : The files $refFastaFileIn, $bamFileIn or/and $vcfVariant are incorrects\n", 0);        # returns the error message
        return 0;
    }
}


# GATK generic: allows to launch any command from GATK
sub gatkGeneric
{
    my ($fileIn, $fileOut, $optionsHachees) = @_;      # recovery of information
    if (toolbox::sizeFile($fileIn)==1)
	{ ##Check if entry file exist and is not empty
		
		#Check if the format is correct
		if (&localFormatCheck($fileIn) == 0)
		{#The file is not a BAM/VCF file
			toolbox::exportLog("ERROR: gatk::gatkGeneric : The file $fileIn is not a BAM/VCF file\n",0);
		}
		
		my $options="";
        my $options=toolbox::extractOptions($optionsHachees);       # extraction of options parameters
        #print $options,"\n";
        if ($options !~ m/-T/) # The type of walker is not informed in the options
        {
            toolbox::exportLog("ERROR: gatk::gatkGeneric : No walker provided (-T option), cannot continue...\n",0);
        }
    
        #The generic command system will transform the FILEIN text by the correct FILENAME
		$options =~ s/FILEIN/$fileIn/i;
		
		#The generic command system will transform the FILEOUT text by the correct FILENAME
		$options =~ s/FILEOUT/$fileOut/i;
		my $command;
		if ($options =~ m/$fileOut/)
		{
			$command=$GATK." ".$options;
		}
		else
		{
			$command=$GATK." ".$options." > ".$fileOut;
		}
        if(toolbox::run($command)==1)
        {
            return 1;
        }
        else        # if one or some previous files don't exist or is/are empty or if gatkGeneric failed
        {
            toolbox::exportLog("ERROR: gatk::gatkGeneric: Uncorrectly done\n", 0);        # returns the error message
        }
    }
    else        # if one or some previous files don't exist or is/are empty or if gatkGeneric failed
    {
        toolbox::exportLog("ERROR: gatk::gatkGeneric : The files $fileIn is incorrect\n", 0);     # returns the error message
    }
}  

#This function will validate that the given file is at least in one of the accepted format (vcf/bam)
sub localFormatCheck{
	my ($file)=@_;
	my $validation =0;
	switch (1)
	{
		case ($file =~ m/vcf$/i){$validation = 1 if (checkFormat::checkFormatVcf($file) == 1)}
		case ($file =~ m/bam$/i){$validation = 1 if (checkFormat::checkFormatSamOrBam($file) == 2)}
		else {toolbox::exportLog("ERROR: bedtools : The file $file is not a BAM/VCF file\n",0);}
	}
	
	return $validation;
	
}

1;
