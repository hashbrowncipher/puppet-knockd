puppet-knockd
==========

This module manages openknockd.

## Class: knockd::server

A class for managing knockd server options

### Parameters

[*package_name*]  
  package name.

[*service_name*]  
  service name (initscript name).

[*usesyslog*]  
  log action messages through syslog().

[*logfile*]  
  log actions directly to a file, (defaults to: /var/log/knockd.log).

[*pidfile*]  
  pidfile to use when in daemon mode, (defaults to: /var/run/knockd.pid).

[*interfacve:
  network interface to listen on (mandatory).

### Examples

```
 class { "knockd":
   interface => 'eth0',
 }
```

## Define: knockd::sequence

A defined type for managing knockd sequences

### Parameters
[*sequence*]  
  port sequence used in single knock mode.

[*open_sequence*]  
  port sequence used in the open knock (two knock mode).

[*close_sequence*]  
  port sequence used in the close knock (two knock mode).

[*one_time_sequences*]  
  file containing the one time sequences to be used. (instead of using a fixed sequence).

[*seq_timeout*]  
  port sequence timeout.

[*tcpflags*]  
  only pay attention to packets that have this flag set.

[*start_command*]  
  command executed when a client makes a correct port knock (both modes).

[*stop_command*]  
  command executed when cmd_timeout seconds are passed or when a close sequence was received (both modes).

[*cmd_timeout*]  
  time to wait between start and stop command (only required in two knock mode).

### Examples
> An Open/Close example that uses a single knock to control access to port 22(ssh):
```
 class { "knockd":
   interface => 'eth3',
 }
 knockd::sequence {
   "SSH":
     sequence      => '2222:udp,3333:tcp,4444:udp',
     seq_timeout   => '15',
     tcpflags      => 'syn,ack',
     start_command => '/usr/sbin/iptables -A INPUT -s %IP% -p tcp --syn --dport 22 -j ACCEPT',
     cmd_timeout   => '10',
     stop_command  => '/usr/sbin/iptables -D INPUT -s %IP% -p tcp --syn --dport 22 -j ACCEPT',
 }
```
> An example using two knocks: the first allow access to port 22(ssh), the second will close the port:
```
 class { "knockd":
   interface => 'eth0',
 }
 knockd::sequence {
   "SSH":
     open_sequence      => '7000,8000,9000',
     close_sequence     => '9000,8000,7000',
     seq_timeout        => '10',
     tcpflags           => 'syn',
     start_command      => '/usr/sbin/iptables -A INPUT -s %IP% -p tcp --syn --dport 22 -j ACCEPT',
     stop_command       => '/usr/sbin/iptables -D INPUT -s %IP% -p tcp --syn --dport 22 -j ACCEPT',
  }
```

### Copyright:
Copyright 2014 Alessio Cassibba (X-Drum), unless otherwise noted.
