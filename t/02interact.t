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

# ->read_temp (max)
{
   $adapter->expect_write_then_read( "\x00", 2 )
      ->returns( "\x7F\xF0" );  # reverse the bytes: i2cget -y 1 0x48 0x00 w

   is( $chip->read_temp->get, 127.9375,
      '->read_temp max result' );

   $adapter->check_and_clear( '->read_temp (max)' );
}

# ->read_temp (zero)
{
   $adapter->expect_write_then_read( "\x00", 2 )
      ->returns( "\x00\x00" );  # reverse the bytes: i2cget -y 1 0x48 0x00 w

   is( $chip->read_temp->get, 0.0,
      '->read_temp zero result' );

   $adapter->check_and_clear( '->read_temp (zero)' );
}

# ->read_temp (small negative)
{
   $adapter->expect_write_then_read( "\x00", 2 )
      ->returns( "\xFF\xC0" );

   is( $chip->read_temp->get, -0.25,
      '->read_temp small negative result' );

   $adapter->check_and_clear( '->read_temp (small negative)' );
}

# ->read_temp (bigger negative)
{
   $adapter->expect_write_then_read( "\x00", 2 )
      ->returns( "\xC9\x00" );

   is( $chip->read_temp->get, -55.0,
      '->read_temp bigger negative result' );

   $adapter->check_and_clear( '->read_temp (bigger negative)' );
}

done_testing;
