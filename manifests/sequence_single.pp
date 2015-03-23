define knockd::sequence_single (
	$sequence = $knockd::params::sequence,
	$seq_timeout = $knockd::params::seq_timeout,
  $command = $knockd::params::command,
	$tcpflags = $knockd::params::tcpflags,
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

	concat::fragment { "knockd_conf_single_${title}":
		target  => $knockd::params::config_file,
		content => template("knockd/knockd.conf-single.erb"),
		order   => 10,
	}
}