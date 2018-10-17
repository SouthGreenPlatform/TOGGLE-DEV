package localConfig;

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
use Exporter;

our @ISA=qw(Exporter);
our @EXPORT=qw($minimap2 $nanoplot $bwa $picard $samtools $GATK $cutadapt $fastqc $java $toggle $fastxTrimmer $tophat2 $bowtie2Build $bowtieBuild $htseqcount $cufflinks $cuffdiff $cuffmerge $tgicl $trinity  $stacks $snpEff $bamutils $crac $cracIndex $bowtie $bowtie2 $atropos $duplicationDetector $plink $bedtools $snmfbin $readseqjar $fastme $abyss $bam2cfg $breakDancer $pindel $fastqStats $hisat2 $stringtie);

#toggle path
our $toggle=$ENV{"TOGGLE_PATH"};

#PATH for Mapping on cluster
our $java = "$ENV{'JAVA_HOME'}/bin/java -jar";

our $bwa = "bwa";
our $picard = "$java $ENV{'PICARD_PATH'}/picard.jar";
#our $picard = "singularity run ~/picard-2.18.14.simg";

our $samtools = "samtools";
our $GATK = "$java $ENV{'GATK_PATH'}/GenomeAnalysisTK.jar";
#our $GATK = "singularity run /usr/local/singularity-2.4/containers/TOGGLE/gatk-3.8.simg";
our $fastqc = "fastqc";

#Path for CutAdapt
our $cutadapt = "cutadapt";

##### FOR RNASEQ analysis
#Path for fastq_trimmer
our $fastxTrimmer="fastx_trimmer";

#Path for tophat2
our $tophat2="tophat2";

#path for bowtie2-build
our $bowtie2Build="bowtie2-build";

#path for bowtie-build
our $bowtieBuild="bowtie-build";

#path for htseqcount
our $htseqcount = "htseq-count";

#path for Cufflinks
our $cufflinks = "cufflinks";
our $cuffdiff = "cuffdiff";
our $cuffmerge = "cuffmerge";

#path for tgicl
our $tgicl = "tgicl";

#path for trinity
our $trinity = "Trinity";

#path for process_radtags
our $stacks = "process_radtags";

#path to snpEff
our $snpEff = "$java $ENV{'SNPEFF_PATH'}/snpEff.jar";

#path to bamutils
our $bamutils = "bamutils";

#path to crac
our $crac = "crac";
our $cracIndex = "crac-index";

#Path to bowtie bowtie2
our $bowtie = "bowtie";
our $bowtie2 = "bowtie2";

# path for atropos
our $atropos="/usr/local/bin/atropos";

#Path for duplicationDetector
our $duplicationDetector = "duplicationDetector.pl";

#Path to bedtools
our $bedtools = "bedtools";

#Path to abyss
# our $abyss = "abyss-pe";
our $abyss = "singularity run /usr/local/singularity-2.4/containers/TOGGLE/abyss-1.9.0.simg";

#Path to breakDancer
our $bam2cfg = "bam2cfg.pl";
our $breakDancer = "breakdancer-max";

#Path to pindel
our $pindel = "pindel";

# path for plink
our $plink="plink";

# path to sNMF
our $snmfbin = "$ENV{'SNMF_PATH'}";

# path to readseq
our $readseqjar = "$java $ENV{'READSEQ_PATH'}/readseq.jar";

#path to FastME
our $fastme= "fastme";

#path to fastq-stats
our $fastqStats= "fastq-stats";

#path to directory with bin for hisat2
our $hisat2 = "$ENV{'HISAT2PATH'}";

#path to stringtie
our $stringtie = "stringtie";


#Path to nanoplot
our $nanoplot="/home/klein/pythonenv/bin/NanoPlot";



#Path to minimap2
our $minimap2="/path/to/minimap2";


1;
