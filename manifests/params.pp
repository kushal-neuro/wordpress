class wordpress::params {
 
   if $::osfamily == 'RedHat'{
    $apachename   = 'httpd' 
    $conffile     = '/etc/httpd/conf/httpd.conf'
    $confsource   = 'puppet:///modules/apache/httpd.conf' 
  } elsif $::osfamily == 'Debain' {
    $apachename   = 'apache2'   
    $conffile     = '/etc/apache2/apache2.conf'
    $confsource   = 'puppet:///modules/apache/apache2.conf'  
  }else {
    fail('This is unsupported destro') 
  }
  
    $root_password = 'Neuro@123'
	$db_name = 'wordpress'
	$db_user = 'wp'
	$db_user_password = 'password123'
	$db_host = 'localhost'
	
	$db_user_host = "${db_user}@${db_host}"	
	$db_user_host_db = "${db_user}@${db_host}/${db_name}.*"
	
	$install_dir          = '/var/www/html'
	$install_url          = 'http://wordpress.org'
	$version              = '3.8'
	$wp_owner              = 'root'
	$wp_group              = 0
   

}
