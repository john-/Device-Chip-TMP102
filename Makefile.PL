use ExtUtils::MakeMaker;

my $preop =
    'perldoc -uT $(VERSION_FROM) | tee $(DISTVNAME)/README.pod > README.pod';

WriteMakefile(
    NAME            => 'Device::Chip::TMP102',
    VERSION_FROM    => 'lib/Device/Chip/TMP102.pm',

    PREREQ_PM => {
        'Data::Bitfield'                    => '0.02',
	'Device::Chip'                      => '0.04',
	'Device::Chip::Base::RegisteredI2C' => '0.10',
        'strict'                            => 0,
        'warnings'                          => 0,
    },
    TEST_REQUIRES => {
        'Test::Device::Chip::Adapter' => 0,
        'Test::More'                  => '0.88',    # done_testing
    },
    dist                => {
	PREOP => $preop,
    },
    
);
