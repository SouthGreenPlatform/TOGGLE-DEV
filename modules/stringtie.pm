package stringtie;

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

use lib qw(../Modules/);
use checkFormat;


sub stringtie
{
    my ($bamFileIn,$gtfFileOut,$gffFile,$optionsHachees)=@_;
    if (toolbox::sizeFile($bamFileIn)==1)            ##Check if the bamfileIn exist and is not empty
    {

        my $options=toolbox::extractOptions($optionsHachees, " ");  ##Get given options by software.config
        ## DEBUG toolbox::exportLog("DEBUG: HTSeq::htseqcount : htseqcount option equals to options $options",1);

        my $command;
        #BAM sorted format is mandatory for stringtie
        if (checkFormat::checkFormatSamOrBam($bamFileIn)==2)
        {
            $command="$stringtie $bamFileIn $options -o $gtfFileOut";
        }
        #if SAM format, the file is automatically converted to BAM and sorted
        if (checkFormat::checkFormatSamOrBam($bamFileIn)==2)
        {
            toolbox::exportLog("ERROR: stringtie error : $bamFileIn is sam and stringtie needs a sorted bam. ABORTED\n",0);
        }
        #Execute command
        if(toolbox::run($command)==1)		## if the command has been executed correctly, export the log
        {
            return 1;
        }
        else
        {
            toolbox::exportLog("ERROR: stringtie::stringtie : ABORTED\n",0);
            return 0;
        }
}


1;


