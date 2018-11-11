#  You may distribute under the terms of either the GNU General Public License
#  or the Artistic License (the same terms as Perl itself)
#

package Device::Chip::TMP102;

use strict;
use warnings;
use 5.010;
use base qw( Device::Chip::Base::RegisteredI2C );
Device::Chip::Base::RegisteredI2C->VERSION('0.10');

use constant REG_DATA_SIZE => 16;

use constant DEBUG => 0;

use utf8;

our $VERSION = '0.01';

use Data::Bitfield qw( bitfield boolfield );

=encoding UTF-8

=head1 NAME

C<Device::Chip::TMP102> - chip driver for an F<TMP102>

=head1 SYNOPSIS

 use Device::Chip::TMP102;

 my $chip = Device::Chip::TMP102->new;
 $chip->mount( Device::Chip::Adapter::...->new )->get;

 printf "Temperature is %2.2f C\n", $chip->read_temp->get;

=head1 DESCRIPTION

This L<Device::Chip> subclass provides specific communication to a
F<Texas Instruments> F<TMP102> attached to a computer via an I²C adapter.

Only a subset of the chip's capabilities are currently accessible through this driver.

The reader is presumed to be familiar with the general operation of this chip;
the documentation here will not attempt to explain or define chip-specific
concepts or features, only the use of this module to access them.

=cut

=head1 MOUNT PARAMETERS

=head2 addr

The I²C address of the device. Can be specified in decimal, octal or hex with
leading C<0> or C<0x> prefixes.

=cut

sub I2C_options {
    my $self   = shift;
    my %params = @_;

    my $addr = delete $params{addr} // 0x40;
    $addr = oct $addr if $addr =~ m/^0/;

    return (
        %params,    # this needs to fixed with resolution of 127570
        addr        => $addr,
        max_bitrate => 400E3,    # TODO:  check if this is from datasheet
    );
}

=head1 METHODS

The following methods documented with a trailing call to C<< ->get >> return
L<Future> instances.

=cut

use constant {
    REG_TEMP => 0x00,    # R
};

=head2 read_temp

   $duty = $chip->read_temp->get

Returns the temperature in degrees Celsius.

=cut

sub read_temp {
    my $self = shift;

    $self->read_reg( REG_TEMP, 1 )->then(
        sub {
            my ($value) = unpack "s<", $_[0];

	    my $lsb = ( $value & 0xff00 );
	    $lsb = $lsb >> 8;

	    my $msb = $value & 0x00ff;

	    printf( "results: %04x\n", $value ) if DEBUG;
	    printf( "msb:     %02x\n", $msb ) if DEBUG;
	    printf( "lsb:     %02x\n", $lsb ) if DEBUG;

	    my $temp = ( $msb << 8 ) | $lsb;

	    # The TMP102 temperature registers are left justified, correctly
	    # right justify them
	    $temp = $temp >> 4;

	    # test for negative numbers
	    if ( $temp & ( 1 << 11 ) ) {

		# twos compliment plus one, per the docs
		$temp = ~$temp + 1;

		# keep only our 12 bits
		$temp &= 0xfff;

		# negative
		$temp *= -1;
	    }

	    # convert to a celsius temp value
	    $temp = $temp / 16;
	    
            Future->done($temp);
        }
    );
}

0x55AA;
