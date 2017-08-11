class wordpress::db inherits wordpress {
  
    class { '::mysql::server':        
        root_password => $root_password,
        databases => {
            "${db_name}" => {
                ensure => 'present',
                charset => 'utf8'
            }
        },

        # Create the user
        users => {
            "${db_user_host}" => {
                ensure => present,
                password_hash => mysql_password("${db_user_password}")
            }
        },

        # Grant privileges to the user
        grants => {
            "${db_user_host_db}" => {
                ensure     => 'present',
                options    => ['GRANT'],
                privileges => ['ALL'],
                table      => "${db_name}.*",
                user       => "${db_user_host}",
            }
        },
    }

    # Install MySQL client and all bindings
    class { '::mysql::client':
        require => Class['::mysql::server'],
        bindings_enable => false
    }


}
