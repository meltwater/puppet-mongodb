# Class: mongodb::logrotate
#
# This module manages mongodb services.
# It provides the functions for mongod and mongos instances.

class mongodb::logrotate {

	anchor { 'mongodb::logrotate::begin': }
	anchor { 'mongodb::logrotate::end': }

	realize(Package['logrotate'])

	file {
		'/etc/logrotate.d/mongodb':
			content => template('mongodb/logrotate.conf.erb'),
			require => [Package['logrotate'],Class[$mongodb::params::installation_type],Class['mongodb::params']],
			before => Anchor['mongodb::logrotate::end']
	}
}
