class mongodb::sourceinstall {

  $download_path = sprintf( 'http://dl.mongodb.org/dl/linux/%s/linux/mongodb-linux-%s-%s.tgz', $::architecture, $::architecture, $mongodb::params::version )
  $full_name = sprintf( 'mongodb-%s-%s', $::architecture, $mongodb::params::version )
  $install_path = "/usr/local/${full_name}"

  $binaries = [ 'mongo', 'mongodump', 'mongofiles', 'mongorestore', 'mongosniff', 'mongod', 'mongoexport', 'mongoimport', 'mongos', 'mongostat' ]

  file { $install_path:
    ensure => directory,
    owner  => $mongodb::params::run_as_user,
    group  => $mongodb::params::run_as_group,
  }

  archive { $full_name :
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

  define make_symlink() {
    file { $name:
      ensure => link,
      path   => "/usr/bin/${name}",
      target => "/etc/alternatives/mongodb/${name}",
    }
  }
  
  make_symlink( $binaries )

}
