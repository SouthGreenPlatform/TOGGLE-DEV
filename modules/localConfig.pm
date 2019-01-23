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
our @EXPORT=qw($flye $nanoplot $bwa $picard $samtools $GATK $cutadapt $fastqc $java $toggle $fastxTrimmer $tophat2 $bowtie2Build $bowtieBuild $htseqcount $cufflinks $cuffdiff $cuffmerge $tgicl $trinity  $stacks $snpEff $bamutils $crac $cracIndex $bowtie $bowtie2 $atropos $duplicationDetector $plink $bedtools $snmfbin $readseqjar $fastme $abyss $bam2cfg $breakDancer $pindel $fastqStats $hisat2 $stringtie);

#toggle path
our $toggle=$ENV{"TOGGLE_PATH"};

#PATH for Mapping on cluster
our $java = "$ENV{'JAVA_HOME'}/bin/java -jar";

our $bwa = "singularity run /usr/local/singularity-2.4/containers/bwa-0.7.12.simg";

our $picard = "singularity run /usr/local/singularity-2.4/containers/picard-2.18.14.simg";

our $samtools = "singularity run /usr/local/singularity-2.4/containers/samtools-1.9.simg";

our $GATK = "singularity run /usr/local/singularity-2.4/containers/gatk-3.8.simg";

our $fastqc = "singularity run /usr/local/singularity-2.4/containers/FastQC-0.11.8.simg";

#Path for CutAdapt
our $cutadapt = "singularity run /usr/local/singularity-2.4/containers/cutadapt-1.9.1.simg";

##### FOR RNASEQ analysis
#Path for fastq_trimmer
our $fastxTrimmer="singularity exec /usr/local/singularity-2.4/containers/FastxToolkit-0.0.13.simg fastx_trimmer";

#Path for tophat2
our $tophat2="singularity exec /usr/local/singularity-2.4/containers/tophat-2.1.1.simg tophat2";

#path for htseqcount
our $htseqcount = "singularity run /usr/local/singularity-2.4/containers/htseq-count-0.11.0.simg";

#path for Cufflinks
our $cufflinks = "singularity run /usr/local/singularity-2.4/containers/cufflinks-2.2.1.simg cufflinks";
our $cuffdiff = "singularity run /usr/local/singularity-2.4/containers/cufflinks-2.2.1.simg cuffdiff";
our $cuffmerge = "singularity run /usr/local/singularity-2.4/containers/cufflinks-2.2.1.simg cuffmerge";

#path for tgicl
our $tgicl = "tgicl";

#path for trinity
our $trinity = "singularity run /usr/local/singularity-2.4/containers/Trinity-2.5.1.simg";

#path for process_radtags
our $stacks = "process_radtags";

#path to snpEff
our $snpEff = "$java $ENV{'SNPEFF_PATH'}/snpEff.jar";

#path to bamutils
#our $bamutils = "bamutils";
our $bamutils = "singularity run /usr/local/singularity-2.4/containers/ngsutils-0.5.9.simg bamutils";

#path to crac
our $crac = "crac";
our $cracIndex = "crac-index";

#Path to bowtie
our $bowtie = "singularity run /usr/local/singularity-2.4/containers/bowtie-1.2.2.simg bowtie";
#path for bowtie-build
our $bowtieBuild="singularity run /usr/local/singularity-2.4/containers/bowtie-1.2.2.simg bowtie-build";

#path for bowtie2
our $bowtie2 = "singularity exec /usr/local/singularity-2.4/containers/bowtie2-2.3.4.3.simg bowtie2";
#path for bowtie2-build
our $bowtie2Build="singularity exec /usr/local/singularity-2.4/containers/bowtie2-2.3.4.3.simg bowtie2-build";

# path for atropos
our $atropos="singularity run /usr/local/singularity-2.4/containers/atropos-1.1.19.simg";

#Path for duplicationDetector
our $duplicationDetector = "duplicationDetector.pl";

#Path to bedtools
#our $bedtools = "bedtools";
our $bedtools = "singularity run /usr/local/singularity-2.4/containers/bedtools-2.27.1.simg";

#Path to abyss
our $abyss = "singularity run /usr/local/singularity-2.4/containers/abyss-1.9.0.simg";

#Path to breakDancer
#our $bam2cfg = "singularity exec /usr/local/singularity-2.4/containers/breakdancer-4e44b43.simg bam2cfg.pl";
#our $breakDancer = "singularity exec /usr/local/singularity-2.4/containers/breakdancer-4e44b43.simg breakdancer-max";
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
#our $fastqStats= "fastq-stats";
our $fastqStats = "singularity run /usr/local/singularity-2.4/containers/ea-utils-1.04.807.simg fastq-stats";

#path to directory with bin for hisat2
our $hisat2 = "$ENV{'HISAT2PATH'}";

#path to stringtie
#our $stringtie = "stringtie";
our $stringtie = "singularity run /usr/local/singularity-2.4/containers/stringtie-1.3.4.simg";

#Path to nanoplot
our $nanoplot="singularity run /usr/local/singularity-2.4/containers/nanoplot-1.19.0.simg";

#Path to flye
our $flye="singularity run /usr/local/singularity-2.4/containers/flye-2.4.simg";


1;
