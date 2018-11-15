#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Device::Chip::Adapter;

use Device::Chip::TMP102;

my $chip = Device::Chip::TMP102->new;

$chip->mount(
    my $adapter = Test::Device::Chip::Adapter->new,
)->get;

# ->read_config
{
    $adapter->expect_write_then_read( "\x01", 2 )
       ->returns( "\xA0\x60" );

    is_deeply( $chip->read_config->get,
       {
	  SD         => '',
	  TM         => '',
	  POL        => '',
	  #	  F          => 1,
	  F0         => 0,
	  F1         => 1,
	  R0         => 1,
	  R1         => 1,
	  OS         => '',
	  EM         => '',
	  AL         => 1,
	  CR0        => '',
	  CR1        => 1,
      },
      '->read_config returns config' );

   $adapter->check_and_clear( '->read_config' );
}

# ->change_config
#{
#   $adapter->expect_write( "\x01\xA1" );#

#   $chip->change_config(
#      EM => 1,
#   )->get;

#   $adapter->check_and_clear( '$chip->change_config' );
#}

done_testing;
