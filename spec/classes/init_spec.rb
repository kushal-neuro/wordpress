require 'spec_helper'
require 'json'

describe 'wordpress' do
  
  let(:facts) do
      {
        :osfamily                  => 'RedHat',
        :operatingsystem           => 'CentOS',
        :operatingsystemmajrelease => '7',
        :root_home       => '/root',
        :puppetversion  => '5.2.0'
      }  
   end
  let(:params) do
    {
      "root_password"    => "Neuro@123",
      "db_user_password" => "password123",
      "apachename"       => "httpd",
      "conffile"         => "/etc/httpd/conf/httpd.conf",
      "confsource"       => "puppet:///modules/apache/httpd.conf",
      "db_name"          => "wordpress",
      "db_user"          => "wp",
      "db_host"          => "localhost",
      "db_user_host"     => "wp@localhost",
      "db_user_host_db"  => "wp@localhost/wordpress.*",
      "install_dir"      => "/var/www/html",
      "install_url"      => "http://wordpress.org",
      "version"          => "3.8",
      "wp_owner"         => "root",
      "wp_group"         => 0
    }
  end

  it {
    is_expected.to contain_package('apache').with({
      'name' => 'httpd',
      'ensure' => 'present',
    })
  }

  it {
    is_expected.to contain_file('configuration file').with({
      'path' => '/etc/httpd/conf/httpd.conf',
      'ensure' => 'file',
      'source' => 'puppet:///modules/apache/httpd.conf',
      'notify' => 'Service[apache-service]',
    })
  }

  
  it {
    is_expected.to contain_service('apache-service').with({
      'name' => 'httpd',
      'hasrestart' => 'true',
    })
  }

  it {
    is_expected.to contain_package('php').with({
      'ensure' => 'present',
    })
  }

  it {
    is_expected.to contain_package('php-pear').with({
      'ensure' => 'present',
    })
  }

  it {
    is_expected.to contain_file('mysql-config-file').with({
      'path' => '/etc/my.cnf.d/server.cnf',
      'mode' => '0644',
      'selinux_ignore_defaults' => 'true',
      'owner' => 'root',
      'group' => 'root',
      'before' => '["Service[mysqld]"]',
    })
  }

  it {
    is_expected.to contain_file('/etc/my.cnf.d').with({
      'ensure' => 'directory',
      'mode' => '0755',
      'owner' => 'root',
      'group' => 'root',
    })
  }

  it {
    is_expected.to contain_package('mysql-server').with({
      'name' => 'mariadb-server',
      'ensure' => 'present',
    })
  }

  it {
    is_expected.to contain_file('/var/log/mariadb/mariadb.log').with({
      'ensure' => 'present',
      'owner' => 'mysql',
      'group' => 'mysql',
      'mode' => 'u+rw',
      'require' => 'Mysql_datadir[/var/lib/mysql]',
    })
  }


  it {
    is_expected.to contain_mysql_datadir('/var/lib/mysql').with({
      'ensure' => 'present',
      'basedir' => '/usr',
      'user' => 'mysql',
      'log_error' => '/var/log/mariadb/mariadb.log',
    })
  }

  it {
    is_expected.to contain_service('mysqld').with({
      'name' => 'mariadb',
      'ensure' => 'running',
      'enable' => 'true',
      'require' => 'Package[mysql-server]',
    })
  }

  it {
    is_expected.to contain_exec('wait_for_mysql_socket_to_open').with({
      'command' => 'test -S /var/lib/mysql/mysql.sock',
      'unless' => 'test -S /var/lib/mysql/mysql.sock',
      'tries' => '3',
      'try_sleep' => '10',
      'require' => 'Service[mysqld]',
      'path' => '/bin:/usr/bin',
    })
  }

  it {
    is_expected.to contain_exec('remove install pass').with({
      'command' => 'mysqladmin -u root --password=$(grep -o \'[^ ]\+$\' /.mysql_secret) password \'\' && rm -f /.mysql_secret',
      'onlyif' => 'test -f /.mysql_secret',
      'path' => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    })
  }

  it {
    is_expected.to contain_mysql_user('root@localhost').with({
      'ensure' => 'present',
      'password_hash' => '*BE77FEA8187054F8B5A2F63E87AF75E296B51094',
      'require' => 'Exec[remove install pass]',
      'before' => '["File[/root/.my.cnf]"]',
    })
  }

  it {
    is_expected.to contain_file('/root/.my.cnf').with({
      'owner' => 'root',
      'mode' => '0600',
      'show_diff' => 'false',
    })
  }

  it {
    is_expected.to contain_mysql_user('wp@localhost').with({
      'ensure' => 'present',
      'password_hash' => '*A0F874BC7F54EE086FCE60A37CE7887D8B31086B',
    })
  }

  it {
    is_expected.to contain_mysql_grant('wp@localhost/wordpress.*').with({
      'ensure' => 'present',
      'options' => '["GRANT"]',
      'privileges' => '["ALL"]',
      'table' => 'wordpress.*',
      'user' => 'wp@localhost',
    })
  }

  it {
    is_expected.to contain_mysql_database('wordpress').with({
      'ensure' => 'present',
      'charset' => 'utf8',
    })
  }

  it {
    is_expected.to contain_package('mysql_client').with({
      'name' => 'mariadb',
      'ensure' => 'present',
    })
  }

  it {
    is_expected.to contain_file('/var/www/html').with({
      'ensure' => 'directory',
      'recurse' => 'true',
      'owner' => 'root',
      'group' => '0',
      'mode' => '0644',
    })
  }

  it {
    is_expected.to contain_package('wget').with({
      'ensure' => 'present',
    })
  }

  it {
    is_expected.to contain_exec('Download wordpress http://wordpress.org/wordpress-3.8.tar.gz to /var/www/html').with({
      'command' => 'wget http://wordpress.org/wordpress-3.8.tar.gz',
      'creates' => '/var/www/html/wordpress-3.8.tar.gz',
      'require' => 'File[/var/www/html]',
      'user' => 'root',
      'group' => '0',
      'path' => '["/bin", "/sbin", "/usr/bin", "/usr/sbin"]',
      'cwd' => '/var/www/html',
      'logoutput' => 'on_failure',
      'before' => '["Exec[Extract wordpress /var/www/html]"]',
    })
  }

  it {
    is_expected.to contain_exec('Extract wordpress /var/www/html').with({
      'command' => 'tar zxvf ./wordpress-3.8.tar.gz --strip-components=1',
      'creates' => '/var/www/html/index.php',
      'user' => 'root',
      'group' => '0',
      'path' => '["/bin", "/sbin", "/usr/bin", "/usr/sbin"]',
      'cwd' => '/var/www/html',
      'logoutput' => 'on_failure',
      'notify' => '["Exec[Change ownership /var/www/html]"]',
    })
  }

  it {
    is_expected.to contain_exec('Change ownership /var/www/html').with({
      'command' => 'chown -R root:0 /var/www/html',
      'refreshonly' => 'true',
      'user' => 'root',
      'group' => '0',
      'path' => '["/bin", "/sbin", "/usr/bin", "/usr/sbin"]',
      'cwd' => '/var/www/html',
      'logoutput' => 'on_failure',
    })
  }

  it {
    is_expected.to contain_concat('/var/www/html/wp-config.php').with({
      'owner' => 'root',
      'group' => '0',
      'mode' => '0644',
      'require' => 'Exec[Extract wordpress /var/www/html]',
      'ensure' => 'present',
      'path' => '/var/www/html/wp-config.php',
      'warn' => 'false',
      'show_diff' => 'true',
      'backup' => 'puppet',
      'replace' => 'true',
      'order' => 'alpha',
      'ensure_newline' => 'false',
    })
  }

  it {
    is_expected.to contain_file('/var/www/html/wp-keysalts.php').with({
      'ensure' => 'present',
      'replace' => 'false',
      'require' => 'Exec[Extract wordpress /var/www/html]',
      'owner' => 'root',
      'group' => '0',
      'mode' => '0644',
    })
  }

  [

"<?php
/**#\@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {\@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * \@since 2.6.0
 */
define('AUTH_KEY',         'P)D3KOb+]Z)||cat=?9iOSro)lQ/s;O(hz w|9K87SN7vUK)wb=zn$<O0wCb65rv');
define('SECURE_AUTH_KEY',  'P*.Ivp3qq-j#a:UFG[!+N F70stjvi.sOCmBMNa=95U}n5H[K[-07j*PlQQ]Q {4');
define('LOGGED_IN_KEY',    '~?f%]9})k+ATd*pyA`$m]twGqcxxDy/-5aMoJ$i8;|pg%ytt^akvelL6l?LviZ_+');
define('NONCE_KEY',        '|H 1+6wg3~o`Ys#zk(SWJX/8,ogX^>Nu^XSDnYF2,>|B!._0RcTmG{ay=&EiBJa4');
define('AUTH_SALT',        '|aeA+>Dv_(*Snd~vX>{Q|r,4,p>z|Loqy?Oz#to|GxR-PfETYj22QswiMw/_T|:+');
define('SECURE_AUTH_SALT', 'VhE4[efC&F|+]|DjSo*)v7?SnF-So`&4Z[SRD6j+JQr xHmW.U:dXSojkiDFlGe~');
define('LOGGED_IN_SALT',   'v(5+!ChNbq`^10T]oZm-MzzP8|sCk/fd_-:s?sU.`}h,?Z= ,p+XK\@J5x`:d3Nvv');
define('NONCE_SALT',       '80MawcG|T><i3sU<1tM[Z46yx?j&9u?) DVUt+g;9{%K9%}`I1V*}{SE) PeQ*+f');

/**#\@-*/
",

  ].map{|k| k.split("\n")}.each do |text|

    it {
      verify_contents(catalogue, '/var/www/html/wp-keysalts.php', text)
    }
  end

  it {
    is_expected.to contain_concat_file('/var/www/html/wp-config.php').with({
      'tag' => '_var_www_html_wp-config.php',
      'owner' => 'root',
      'group' => '0',
      'mode' => '0644',
      'replace' => 'true',
      'backup' => 'puppet',
      'show_diff' => 'true',
      'order' => 'alpha',
      'ensure_newline' => 'false',
    })
  }

  it {
    is_expected.to contain_concat_fragment('/var/www/html/wp-config.php keysalts').with({
      'target' => '/var/www/html/wp-config.php',
      'tag' => '_var_www_html_wp-config.php',
      'order' => '10',
      'source' => '/var/www/html/wp-keysalts.php',
    })
  }

  it {
    is_expected.to contain_concat_fragment('/var/www/html/wp-config.php body').with({
      'target' => '/var/www/html/wp-config.php',
      'tag' => '_var_www_html_wp-config.php',
      'order' => '20',
      'content' => '/**
 * The base configurations of the WordPress.
 *
 * This file has the following configurations: MySQL settings, Table Prefix,
 * Secret Keys, WordPress Language, and ABSPATH. You can find more information
 * by visiting {@link http://codex.wordpress.org/Editing_wp-config.php Editing
 * wp-config.php} Codex page. You can get the MySQL settings from your web host.
 *
 * This file is used by the wp-config.php creation script during the
 * installation. You don\'t have to use the web site, you can just copy this file
 * to "wp-config.php" and fill in the values.
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define(\'DB_NAME\', \'wordpress\');

/** MySQL database username */
define(\'DB_USER\', \'wp\');

/** MySQL database password */
define(\'DB_PASSWORD\', \'password123\');

/** MySQL hostname */
define(\'DB_HOST\', \'localhost\');

/** Database Charset to use in creating database tables. */
define(\'DB_CHARSET\', \'utf8\');

/** The Database Collate type. Don\'t change this if in doubt. */
define(\'DB_COLLATE\', \'\');

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each a unique
 * prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = \'wp_\';

/**
 * WordPress Localized Language, defaults to English.
 *
 * Change this to localize WordPress. A corresponding MO file for the chosen
 * language must be installed to wp-content/languages. For example, install
 * de_DE.mo to wp-content/languages and set WPLANG to \'de_DE\' to enable German
 * language support.
 */
define(\'WPLANG\', \'\');

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 */
define(\'WP_DEBUG\', false);

/* That\'s all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined(\'ABSPATH\') )
	define(\'ABSPATH\', dirname(__FILE__) . \'/\');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . \'wp-settings.php\');
',
    })
  }

  it {
    is_expected.to compile.with_all_deps
    File.write(
      'catalogs/wordpress.json',
      PSON.pretty_generate(catalogue)
    )
  }
end
