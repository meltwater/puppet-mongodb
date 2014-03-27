#class doc
class mongodb::sourceinstall {

  anchor { 'mongodb::install::begin': }
  anchor { 'mongodb::install::end': }

  $full_name     = sprintf( 'mongodb-linux-%s-%s', $::architecture, $mongodb::params::version )
  $download_path = sprintf( 'http://fastdl.mongodb.org/linux/%s.tgz', $full_name )
  $install_path  = "/usr/local/${full_name}"

  $binaries = [ 'mongo', 'mongodump', 'mongofiles', 'mongorestore', 'mongosniff', 'mongod', 'mongoexport', 'mongoimport', 'mongos', 'mongostat' ]

  user { $mongodb::params::run_as_user:
    comment => 'MongoDB Database Server',
    home    => $install_path,
    shell   => '/sbin/nologin',
  }->
  group { $mongodb::params::run_as_group:
  }->
  file { $mongodb::params::logdir:
    ensure => directory,
    owner  => $mongodb::params::run_as_user,
    group  => $mongodb::params::run_as_group,
    mode   => '0775',
  }

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

  mongodb::source_symlink{ $binaries: }

  exec { 'cleanup':
      command => "/bin/mv ${install_path}/${full_name}/* ${install_path} && rmdir ${install_path}/${full_name}",
      creates => "${install_path}/bin/mongo",
  }

  Archive[$full_name] -> Exec['cleanup']

}
