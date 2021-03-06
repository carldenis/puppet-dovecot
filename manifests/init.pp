# Class: dovecot
#
# Install, enable and configure the Dovecot IMAP server.
# Options:
#  $plugins:
#    Array of plugin sub-packages to install. Default: empty
#
class dovecot (
  $plugins                    = [],
  # dovecot.conf
  $protocols                  = undef,
  $listen                     = undef,
  $login_greeting             = undef,
  $login_trusted_networks     = undef,
  $verbose_proctitle          = undef,
  $shutdown_clients           = undef,
  # 10-auth.conf
  $disable_plaintext_auth     = undef,
  $auth_username_chars        = undef,
  $auth_username_format       = undef,
  $auth_mechanisms            = 'plain',
  $auth_include               = [ 'system' ],
  # 10-logging.conf
  $log_path                   = undef,
  $log_timestamp              = undef,
  $auth_verbose               = undef,
  $auth_debug                 = undef,
  $mail_debug                 = undef,
  # 10-mail.conf
  $mail_location              = undef,
  # 10-master.conf
  $default_process_limit      = undef,
  $default_client_limit       = undef,
  $auth_listener_userdb_mode  = undef,
  $auth_listener_userdb_user  = undef,
  $auth_listener_userdb_group = undef,
  $auth_listener_postfix      = false,
  $lmtp_unix_listener         = undef,
  $lmtp_postfix_user          = undef,
  # 10-ssl.conf
  $ssl                        = undef,
  $ssl_cert                   = '/etc/pki/dovecot/certs/dovecot.pem',
  $ssl_key                    = '/etc/pki/dovecot/private/dovecot.pem',
  $ssl_cipher_list            = undef,
  # 15-lda.conf
  $postmaster_address         = undef,
  $hostname                   = undef,
  $lda_mail_plugins           = undef,
  $recipient_delimiter        = undef,
  # 20-imap.conf
  $mail_max_userip_connections     = 10,
  # 20-lmtp.conf
  $lmtp_mail_plugins          = undef,
  # 90-sieve.conf
  $sieve                      = '~/.dovecot.sieve',
  $sieve_dir                  = '~/sieve',
  # auth-sql.conf.ext
  $auth_sql_userdb_static     = undef

) {

  include dovecot::params

  # All files in this scope are dovecot configuration files
  File {
    notify  => Service['dovecot'],
    require => Package[$dovecot::params::package_name],
  }

  # Install plugins (sub-packages)
  dovecot::plugin { $plugins: before => Package[$dovecot::params::package_name] }

  # Main package and service it provides
  package { $dovecot::params::package_name: ensure => installed }
  service { 'dovecot':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => File['/etc/dovecot/dovecot.conf'],
  }

  # Main configuration file
  file { '/etc/dovecot/dovecot.conf':
    content => template('dovecot/dovecot.conf.erb'),
  }

  # Configuration file snippets which we modify
  file { '/etc/dovecot/conf.d/10-auth.conf':
    content => template('dovecot/conf.d/10-auth.conf.erb'),
  }
  file { '/etc/dovecot/conf.d/10-logging.conf':
    content => template('dovecot/conf.d/10-logging.conf.erb'),
  }
  file { '/etc/dovecot/conf.d/10-mail.conf':
    content => template('dovecot/conf.d/10-mail.conf.erb'),
  }
  file { '/etc/dovecot/conf.d/10-master.conf':
    content => template('dovecot/conf.d/10-master.conf.erb'),
  }
  file { '/etc/dovecot/conf.d/10-ssl.conf':
    content => template('dovecot/conf.d/10-ssl.conf.erb'),
  }
  file { '/etc/dovecot/conf.d/15-lda.conf':
    content => template('dovecot/conf.d/15-lda.conf.erb'),
  }
  file { '/etc/dovecot/conf.d/20-imap.conf':
    content => template('dovecot/conf.d/20-imap.conf.erb'),
  }
  file { '/etc/dovecot/conf.d/20-lmtp.conf':
    content => template('dovecot/conf.d/20-lmtp.conf.erb'),
  }
  file { '/etc/dovecot/conf.d/90-sieve.conf':
    content => template('dovecot/conf.d/90-sieve.conf.erb'),
  }
  file { '/etc/dovecot/conf.d/auth-sql.conf.ext':
    content => template('dovecot/conf.d/auth-sql.conf.ext.erb'),
  }

}

