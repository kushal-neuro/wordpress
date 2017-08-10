# Class: wordpress
# ===========================
#
# Full description of class wordpress here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'wordpress':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class wordpress (
  $apachename       = $wordpress::params::apachename, 
  $conffile         = $wordpress::params::conffile, 
  $confsource       = $wordpress::params::confsource, 
  $root_password    = $wordpress::params::root_password,
  $db_name          = $wordpress::params::db_name, 
  $db_user          = $wordpress::params::db_user,
  $db_user_password = $wordpress::params::db_user_password,
  $db_host          = $wordpress::params::db_host, 
  $db_user_host     = $wordpress::params::db_user_host, 
  $db_user_host_db  = $wordpress::params::db_user_host_db, 
  $install_dir      = $wordpress::params::install_dir, 
  $install_url      = $wordpress::params::install_url, 
  $version          = $wordpress::params::version, 
  $wp_owner         = $wordpress::params::wp_owner, 
  $wp_group         = $wordpress::params::wp_group
  
) inherits wordpress::params {
 
 validate_string($db_name,$db_user)
 #contain wordpress::apache
 #contain wordpress::php
 #contain wordpress::db
 contain wordpress::app
}
