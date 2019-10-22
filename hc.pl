use strict;
use warnings;
use v5.10;	# For say

my $temperatureRecordInterval = 5;
my $tempSensorSerial = '<DS18B20 serial>';

my $minTemperature = 20;
my $startStop = 5;
my $pinState = 0;


for (;;) {
	my $temperature = ReadTemperature($tempSensorSerial);
	if (defined $temperature) {
		if ($pinState = 0) {
			if ($temperature < ($minTemperature - $startStop)) {
				WriteIOPin($pinNumber, 1);
			}
		} else {
			if ($temperature > $minTemperature) {
				WriteIOPin(pinNumber, 0);
			}
		}
	}
	sleep $temperatureRecordInterval;
}

sub ReadTemperature {
	my $tempSensorSerial = $_[0];

	open (my $fileHandle, '<', '/sys/bus/w1/devices/' . $tempSensorSerial . '/w1_slave')
		or die "Unable to open file, $!";

	my @temp_file=<$fileHandle>;

	close ($fileHandle)
		or warn "Unable to close the file handle: $!";

	print $temp_file[0];
	print $temp_file[1];

	if ($temp_file[0] =~ /YES/) {
		# print "goeie.\n";
		my @string_parts = split /t=/, $temp_file[1];
		my $temperature = $string_parts[1] / 1000;
		# print "Temperature = $temperature\n";
		return $temperature;
	}
	print "Temperature reading was not valid.\n";
	return undef;
}

sub WriteIOPin {
	my $pin = $_[0];
	my $state = $_[1];

	# write state to pin
	open (FH, '>', '/sys/class/gpio/gpio' . $pin  . '/value')
		or die $!;

	print FH $state;

	close(FH);

	# Flip state
	$pinState = $state;
}
