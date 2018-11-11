#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Device::Chip::Adapter;

use Device::Chip::TMP102;

require_ok( 'Device::Chip::TMP102' );

my $chip = new_ok( 'Device::Chip::TMP102' );

$chip->mount(
   my $adapter = Test::Device::Chip::Adapter->new,
)->get;

# ->read_temp
{
   $adapter->expect_write_then_read( "\x00", 2 )
      ->returns( "\x1C\x00" );  # reverse the bytes: i2cget -y 1 0x48 0x00 w

   is( $chip->read_temp->get, 28.0,
      '->read_temp result' );

   $adapter->check_and_clear( '->read_temp' );
}

done_testing;
