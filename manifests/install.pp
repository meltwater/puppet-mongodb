# Class: mongodb::install
#
#
class mongodb::install {

	anchor { 'mongodb::install::begin': }
	anchor { 'mongodb::install::end': }

	package { 'mongodb':
		ensure  => installed,
		require => Anchor['mongodb::install::begin'],
		before => Anchor['mongodb::install::end'],
	}

}
