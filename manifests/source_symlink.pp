#doc
define mongodb::source_symlink() {
  file { $name:
    ensure => link,
    path   => "/usr/bin/${name}",
    target => "/etc/alternatives/mongodb/bin/${name}",
  }
}
