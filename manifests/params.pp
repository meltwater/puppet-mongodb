# Class: mongodb::params
#
#
class mongodb::params {

	$run_as_user = 'mongodb'
	$run_as_group = 'mongodb'

	# directorypath to store db directory in
	# subdirectories for each mongo instance will be created

	$dbdir = '/var/lib'

	# numbers of files (days) to keep by logrotate

	$logrotatenumber = 7

	# directory for mongo logfiles

	$logdir = '/var/log/mongodb'
}
