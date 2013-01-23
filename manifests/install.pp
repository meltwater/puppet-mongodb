# Class: mongodb::install
#
#
class mongodb::install {

	package { 'mongodb':
		ensure  => installed,
	}

}
