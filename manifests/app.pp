class wordpress::app inherits wordpress {

  ## Download and extract
  $install_file_name = "wordpress-${version}.tar.gz"
  
  
  ## Resource defaults
  File {
    owner  => $wp_owner,
    group  => $wp_group,
    mode   => '0644',
  }
  Exec {
    path      => ['/bin','/sbin','/usr/bin','/usr/sbin'],
    cwd       => $install_dir,
    logoutput => 'on_failure',
  }
  
  
   ## Installation directory
  if ! defined(File[$install_dir]) {
    file { $install_dir:
      ensure  => directory,
      recurse => true,
    }
  } else {
    notice("Warning: cannot manage the permissions of ${install_dir}, as another resource (perhaps apache::vhost?) is managing it.")
  }
  
  package { 'wget':
	 name    => 'wget',
	 ensure  => present,
   }  
  
  exec { "Download wordpress ${install_url}/wordpress-${version}.tar.gz to ${install_dir}":
    command => "wget ${install_url}/${install_file_name}",
    creates => "${install_dir}/${install_file_name}",
    require => File[$install_dir],
    user        => $wp_owner,
    group       => $wp_group,
  }
  -> exec { "Extract wordpress ${install_dir}":
    command => "tar zxvf ./${install_file_name} --strip-components=1",
    creates => "${install_dir}/index.php",
    user        => $wp_owner,
    group       => $wp_group,
  }
  ~> exec { "Change ownership ${install_dir}":
    command     => "chown -R ${wp_owner}:${wp_group} ${install_dir}",
    refreshonly => true,
    user        => $wp_owner,
    group       => $wp_group,
  }
  
  ## Configure wordpress
  #
  concat { "${install_dir}/wp-config.php":
    owner   => $wp_owner,
    group   => $wp_group,
    mode    => '0644',
    require => Exec["Extract wordpress ${install_dir}"],
  }
  
  
    file { "${install_dir}/wp-keysalts.php":
      ensure  => present,
      content => template('wordpress/wp-keysalts.php.erb'),
      replace => false,
      require => Exec["Extract wordpress ${install_dir}"],
    }
    concat::fragment { "${install_dir}/wp-config.php keysalts":
      target  => "${install_dir}/wp-config.php",
      source  => "${install_dir}/wp-keysalts.php",
      order   => '10',
      require => File["${install_dir}/wp-keysalts.php"],
    }
    
    concat::fragment { "${install_dir}/wp-config.php body":
      target  => "${install_dir}/wp-config.php",
      content => template('wordpress/wp-config.php.erb'),
      order   => '20',
    }
  
  

}
