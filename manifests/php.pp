class wordpress::php inherits wordpress {
  
 $phpname = $osfamily ? {
    'Debian'    => 'php5',
    'RedHat'    => 'php',
    default     => warning('This distribution is not supported by the PHP module'),
  }
        
  package { 'php':
    name    => $phpname,
    ensure  => present,
  }
          
  package { 'php-pear':
    ensure  => present,
  }
          
 
}
