# Class: knockd::init
#
# A class for managing knockd configuration.
#
# Parameters:
# sequence:
#   port sequence used in single knock mode.
#
# open_sequence:
#   port sequence used in the open knock (two knock mode).
#
# close_sequence:
#   port sequence used in the close knock (two knock mode).
#
# one_time_sequences:
#   file containing the one time sequences to be used. (instead of using a fixed sequence).
#
# seq_timeout:
#   port sequence timeout.
#
# tcpflags:
#   only pay attention to packets that have this flag set.
#
# start_command:
#   command executed when a client makes a correct port knock (both modes).
#
# stop_command:
#   command executed when cmd_timeout seconds are passed or when a close sequence was received (both modes).
#
# cmd_timeout:
#   time to wait between start and stop command (only required in two knock mode).
#
# Examples:
#
# An Open/Close example that uses a single knock to control access to port 22(ssh):
#
# class { "knockd":
# 	interface => 'eth3',
# }
# knockd::sequence {
# 	"SSH":
# 		sequence      => '2222:udp,3333:tcp,4444:udp',
# 		seq_timeout   => '15',
# 		tcpflags      => 'syn,ack',
# 		start_command => '/usr/sbin/iptables -A INPUT -s %IP% -p tcp --syn --dport 22 -j ACCEPT',
# 		cmd_timeout   => '10',
# 		stop_command  => '/usr/sbin/iptables -D INPUT -s %IP% -p tcp --syn --dport 22 -j ACCEPT',
# }
#
# An example using two knocks: the first allow access to port 22(ssh), the second will close the port:
#
# class { "knockd":
# 	interface => 'eth0',
# }
# knockd::sequence {
# 	"SSH":
# 		open_sequence      => '7000,8000,9000',
# 		close_sequence     => '9000,8000,7000',
# 		seq_timeout        => '10',
# 		tcpflags           => 'syn',
# 		start_command      => '/usr/sbin/iptables -A INPUT -s %IP% -p tcp --syn --dport 22 -j ACCEPT',
# 		stop_command       => '/usr/sbin/iptables -D INPUT -s %IP% -p tcp --syn --dport 22 -j ACCEPT',
# }
#
# Copyright 2014 Alessio Cassibba (X-Drum), unless otherwise noted.
#
define knockd::sequence (
	$sequence = $knockd::params::sequence,
	$open_sequence = $knockd::params::open_sequence,
	$close_sequence = $knockd::params::close_sequence,
	$one_time_sequences = $knockd::params::one_time_sequences,
	$seq_timeout = $knockd::params::seq_timeout,
	$tcpflags = $knockd::params::tcpflags,
	$start_command = $knockd::params::start_command,
	$stop_command = $knockd::params::stop_command,
	$cmd_timeout = $knockd::params::cmd_timeout,
) {
	include knockd::params

	if $sequence == undef {
		err("Please specify a valid value for sequence.")
	}
	if $seq_timeout == undef {
		err("Please specify a valid value for timeout")
	}
	if $tcpflags == undef {
		err("Please specify a valid value for tcpflags.")
	}

	if $sequence {
		if ($start_command == undef) or ($stop_command == undef) {
			err("Please specify a valid value for both start_command and stop_command.")
		}
		if $cmd_timeout == undef {
			err("Please specify a valid value for sequence.")
		}
	}
	else {
		err("Please specify a valid value for sequence.")
	}

	if ($open_sequence) and ($close_sequence) {
		if ($start_command == undef) or ($stop_command == undef) {
			err("Please specify a valid value for command.")
		}
	}
	else {
		err("Please specify a valid value for both open_sequence and close_sequence.")
	}

	concat::fragment { "knockd_conf_snippet_${title}":
		target  => $knockd::params::config_file,
		content => template("knockd/knockd.conf-snippet.erb"),
		order   => 10,
	}
}