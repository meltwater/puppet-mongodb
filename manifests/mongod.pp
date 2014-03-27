#doc
define mongodb::mongod (
        $mongod_instance = $name,
        $mongod_bind_ip = '',
        $mongod_port = 27017,
        $mongod_replSet = '',
        $mongod_enable = true,
        $mongod_running = true,
        $mongod_configsvr = false,
        $mongod_shardsvr = false,
        $mongod_logappend = true,
        $mongod_rest = true,
        $mongod_fork = true,
        $mongod_add_options = ''
) {
        file {
                "/etc/mongod_${mongod_instance}.conf":
                        content => template('mongodb/mongod.conf.erb'),
                        mode    => '0755',
                        # no auto restart of a db because of a config change
                        #       notify  => Class['mongodb::service'],
                        require => Class[$mongodb::params::installation_type];
                "/etc/init.d/mongod_${mongod_instance}":
                        content => template('mongodb/mongod-init.conf.erb'),
                        mode    => '0755',
                        require => Class[$mongodb::params::installation_type],
        }

        service { "mongod_${mongod_instance}":
                ensure     => $mongod_running,
                enable     => $mongod_enable,
                hasstatus  => true,
                hasrestart => true,
                require    => [File["/etc/init.d/mongod_${mongod_instance}"],File["/etc/mongod_${mongod_instance}.conf"],Service['mongod'],Exec['add_mongod_service']],
                before     => Anchor['mongodb::end']
        }

        exec { 'add_mongod_service':
                command   => "/sbin/chkconfig --add mongod_${mongod_instance}",
                path      => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
                onlyif    =>  "test `/sbin/chkconfig --list | /bin/grep mongod_${mongod_instance} | /usr/bin/wc -l` -eq 0",
                require   => File["/etc/init.d/mongod_${mongod_instance}"]
        }
}

