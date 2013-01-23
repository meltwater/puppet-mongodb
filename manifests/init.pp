# Class: mongodb

class mongodb inherits mongodb::params {

	anchor{ 'mongodb::begin':
		before => Anchor['mongodb::install::begin'],
	}

	anchor { 'mongodb::end': }

	class { 'mongodb::logrotate':
		require => Anchor['mongodb::install::end'],
		before => Anchor['mongodb::end'],
	}

	case $operatingsystem {
		/(?i)(Debian|Ubuntu|RedHat|CentOS)/: {
			class { 'mongodb::install': }
		}
		default: {
			fail "Unsupported OS ${operatingsystem} in 'mongodb' module"
		}
	}

	# stop and disable default mongod

	service {
		"mongod":
			ensure => stopped,
			enable => false,
			hasstatus => true,
			hasrestart => true,
			require => Anchor['mongodb::install::end'],
			before => Anchor['mongodb::end'],
	}

	# remove not wanted startup script, because it would kill all mongod instances
	# and not only the default mongod

	file {
		"/etc/init.d/mongod":
			ensure => absent,
			require => Service["mongod"],
			before => Anchor['mongodb::end'],
	}


	define mongod (
		$mongod_instance = $name,
		$mongod_bind_ip = '',
		$mongod_port = 27017,
		$mongod_replSet = '',
		$mongod_enable = 'true',
		$mongod_running = 'true',
		$mongod_configsvr = 'false',
		$mongod_shardsvr = 'false',
		$mongod_logappend = 'true',
		$mongod_rest = 'true',
		$mongod_fork = 'true',
		$mongod_add_options = ''
	) {
		file {
			"/etc/mongod_${mongod_instance}.conf":
				content => template('mongodb/mongod.conf.erb'),
				mode    => '0755',
				# no auto restart of a db because of a config change
				#	notify  => Class['mongodb::service'],
				require => Class['mongodb::install'];
			"/etc/init.d/mongod_${mongod_instance}":
				content => template('mongodb/mongod-init.conf.erb'),
				mode    => '0755',
				require => Class['mongodb::install'],
		}

		service { "mongod_${mongod_instance}":
			enable     => $mongod_enable,
			ensure     => $mongod_running,
			hasstatus  => true,
			hasrestart => true,
			require    => [File["/etc/init.d/mongod_${mongod_instance}"],Service['mongod'],Exec["add_mongod_service"]],
			before     => Anchor['mongodb::end']
		}

		exec { "add_mongod_service":
    	command   => "/sbin/chkconfig --add mongod_${mongod_instance}",
    	path      => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    	onlyif    =>  "test `/sbin/chkconfig --list | /bin/grep mongod_${mongod_instance} | /usr/bin/wc -l` -eq 0",
  	}
	}

	define mongos (
		$mongos_instance = $name,
		$mongos_bind_ip = '',
		$mongos_port = 27017,
		$mongos_configServers,
		$mongos_enable = 'true',
		$mongos_running = 'true',
		$mongos_logappend = 'true',
		$mongos_fork = 'true',
		$mongos_add_options = ''
	) {
		file {
			"/etc/mongos_${mongos_instance}.conf":
				content => template('mongodb/mongos.conf.erb'),
				mode    => '0755',
				# no auto restart of a db because of a config change
				#	notify  => Class['mongodb::service'],
				require => Class['mongodb::install'];
			"/etc/init.d/mongos_${mongos_instance}":
				content => template('mongodb/mongos-init.conf.erb'),
				mode    => '0755',
				require => Class['mongodb::install'],
		}

		service { "mongos_${mongos_instance}":
			enable     => $mongos_enable,
			ensure     => $mongos_running,
			hasstatus  => true,
			hasrestart => true,
			require    => [File["/etc/init.d/mongos_${mongos_instance}"],Service['mongod'],Exec["add_mongos_service"]],
			before     => Anchor['mongodb::end']
		}

		exec { "add_mongos_service":
    	command   => "/sbin/chkconfig --add mongos_${mongos_instance}",
    	path      => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    	onlyif    =>  "test `/sbin/chkconfig --list | /bin/grep mongos_${mongos_instance} | /usr/bin/wc -l` -eq 0",
  	}
	}

}

