define mongodb::mongos (
        $mongos_instance = $name,
        $mongos_bind_ip = '',
        $mongos_port = 27017,
        $mongos_configServers,
        $mongos_enable = 'true',
        $mongos_running = 'true',
        $mongos_logappend = 'true',
        $mongos_fork = 'true',
        $mongos_add_options = ''
) {
        file {
                "/etc/mongos_${mongos_instance}.conf":
                        content => template('mongodb/mongos.conf.erb'),
                        mode    => '0755',
                        # no auto restart of a db because of a config change
                        #       notify  => Class['mongodb::service'],
                        require => Class[$mongodb::params::installation_type];
                "/etc/init.d/mongos_${mongos_instance}":
                        content => template('mongodb/mongos-init.conf.erb'),
                        mode    => '0755',
                        require => Class[$mongodb::params::installation_type],
        }

        service { "mongos_${mongos_instance}":
                enable     => $mongos_enable,
                ensure     => $mongos_running,
                hasstatus  => true,
                hasrestart => true,
                require    => [File["/etc/init.d/mongos_${mongos_instance}"],Service['mongod'],Exec["add_mongos_service"]],
                before     => Anchor['mongodb::end']
        }

        exec { "add_mongos_service":
                command   => "/sbin/chkconfig --add mongos_${mongos_instance}",
                path      => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
                onlyif    =>  "test `/sbin/chkconfig --list | /bin/grep mongos_${mongos_instance} | /usr/bin/wc -l` -eq 0",
        }
}
