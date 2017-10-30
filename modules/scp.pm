package scp;

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
use Data::Dumper;

#Picking up the NFS mount

sub mountPoint {# Based on the mounted volume, will provide a hash with VolName => IP/DNS
	
	my $mounted = `df -h | grep ":"`;
	chomp $mounted;
	my @listVolumes = split /\n/, $mounted;
	my %volumes;
	while (@listVolumes)
	{
		my $currentVolume = shift @listVolumes;
		my @fields = split /\s+/, $currentVolume;
		my ($ip)=split /:/, $fields[0];
		my $name = pop @fields;
		$volumes{$name} = $ip;
	}
	
	return \%volumes;
}

sub transfer { #From a list of folder, will perform a rsync over ssh transfer (normally ok in cluster) and provide a list of new name
 	my ($folderIn) = @_;
	
	my $mount = &mountPoint;
	print Dumper ($mount);
	
}



1;

=head1 NAME

    Package I<scp> 

=head1 SYNOPSIS

        use scp;
    
    
        
=head1 DESCRIPTION

    this module allows the SCP transfer on nodes when working in scheduler/NPC mode
    
=head2 FUNCTIONS


=head3 

=head1 AUTHORS

Intellectual property belongs to IRD, CIRAD and South Green developpement plateform 
Written by Cecile Monat, Ayite Kougbeadjo, Marilyne Summo, Cedric Farcy, Mawusse Agbessi, Christine Tranchant and Francois Sabot

=head1 SEE ALSO

L<http://toggle.southgreen.fr/>

=cut