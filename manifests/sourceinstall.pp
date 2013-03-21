class mongodb::sourceinstall {

	anchor { 'mongodb::install::begin': }
	anchor { 'mongodb::install::end': }

  $full_name     = sprintf( 'mongodb-linux-%s-%s', $::architecture, $mongodb::params::version )
  $download_path = sprintf( 'http://downloads.mongodb.org/linux/%s.tgz', $full_name )
  $install_path  = "/usr/local/$full_name"

  $binaries = [ 'mongo', 'mongodump', 'mongofiles', 'mongorestore', 'mongosniff', 'mongod', 'mongoexport', 'mongoimport', 'mongos', 'mongostat' ]

  file { $install_path:
    owner  => $mongodb::params::run_as_user,
    group  => $mongodb::params::run_as_group,
  }

  archive { $full_name:
    url        => $download_path ,
    target     => $install_path,
    src_target => '/tmp',
    checksum   => false,
    require    => File[$install_path],
  }

  file { '/etc/alternatives/mongodb':
    ensure => link,
    target => $install_path
  }

  mongodb::source_symlink{ $binaries: }o

  exec { "mv2rightspot":
      command => "/bin/mv $install_path/$full_name /usr/local",
      creates => "$install_path/bin/mongo"
  }

  Archive["$full_name"] -> Exec['mv2rightspot']

}
