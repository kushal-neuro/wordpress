class wordpress::apache inherits wordpress {

  #notice("RedHat $conffile")
 
  package { 'apache':
	 name    => $apachename,
	 ensure  => present,
   }

   file { 'configuration file':
     path    => $conffile,
     ensure  => file,
     source  => $confsource,
     notify  => Service['apache-service'],
  }
        
  service { 'apache-service':
     name          => $apachename,
     hasrestart    => true,
  }
 
}
