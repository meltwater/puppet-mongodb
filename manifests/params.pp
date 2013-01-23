# Class: mongodb::params
#
#
class mongodb::params {

	$run_as_user = 'mongod'
	$run_as_group = 'mongod'

	# directorypath to store db directory in
	# subdirectories for each mongo instance will be created

	$dbdir = '/var/lib'

	# numbers of files (days) to keep by logrotate

	$logrotatenumber = 7

	# directory for mongo logfiles

	$logdir = '/var/log/mongo'
}
