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
			class { $mongodb::params::installation_type: }
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

}

