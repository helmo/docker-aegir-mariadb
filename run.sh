#!/bin/bash
# needed variables:
# AEGIR_SITE
# AEGIR_EMAIL
# AEGIR_DB_PASSWORD
# AEGIR_VERSION
#


# Start ssh early to be able to login for debugging.
service openssh-server start

echo "Install mysql:"

MYSQL="/usr/bin/mysqld_safe"
MYSQL_ADMIN="/usr/bin/mysqladmin"
INITDB="/usr/bin/mysql_install_db"

chown -R mysql:mysql /var/log/mysql

# test if DATADIR is existent
if [ ! -d $DATADIR ]; then
  echo "Creating MariaDB data at $DATADIR"
  mkdir -p $DATADIR
fi

# test if DATADIR has content
if [ ! "$(ls -A $DATADIR)" ]; then
  echo "Initializing MariaDB Database at $DATADIR"
  chown -R mysql $DATADIR
  $INITDB

  echo "starting MariaDB server..."
  /usr/bin/mysqld_safe &
  MYSQL_PID=$!

  sleep 6

  # Finally, grant access to off-container connections
  GRANT="GRANT ALL PRIVILEGES ON *.* to root@'%' IDENTIFIED BY '${MYSQL_ROOT_PW}' WITH GRANT OPTION;\
  		UPDATE user SET Password=PASSWORD('$MYSQL_ROOT_PW') WHERE User='root';\
       	FLUSH PRIVILEGES;"
  echo "$GRANT" | mysql -u root mysql

  echo "server running."
else
  echo "starting MariaDB server..."
  /usr/bin/mysqld_safe &
  MYSQL_PID=$!
  sleep 6
fi

#chmod +x /solr_install.sh
#/solr_install.sh

set -x
echo "init aegir"
if [ -e "/root/installed" ] ; then
	echo "Host already installed"
else 
	GRANT="GRANT ALL PRIVILEGES ON *.* TO 'aegir_root'@'%' IDENTIFIED BY '${AEGIR_DB_PASSWORD}' WITH GRANT OPTION;\
	       FLUSH PRIVILEGES;"
	echo "$GRANT" | mysql -u root -h localhost -p$MYSQL_ROOT_PW

	apt-get -y install ssmtp

	adduser --system --group --home /var/aegir aegir
	adduser aegir www-data    #make aegir a user of group www-data
	chsh aegir -s /bin/bash

	chown -R www-data:www-data /var/log/apache2
	chown -R aegir:www-data /var/aegir

	phpmemory_limit=256M #or what ever you want it set to
	sed -i 's/memory_limit = .*/memory_limit = '${phpmemory_limit}'/' /etc/php5/apache2/php.ini

	a2enmod rewrite

	ln -s /var/aegir/config/apache.conf /etc/apache2/conf-enabled/aegir.conf

	echo -e "Defaults:aegir  !requiretty\naegir ALL=NOPASSWD: /usr/sbin/apache2ctl" >> /etc/sudoers.d/aegir
	chmod 0440 /etc/sudoers.d/aegir

	ln -s /var/aegir/drush/drush /usr/local/bin/drush

	su -s /bin/sh aegir -c "sh /aegir_install.sh"

	touch /root/installed

	# Stop apache, supervisor will start it later and keep it running.
	apache2ctl stop

	mkdir /var/aegir/drush
	ln -s /usr/bin/drush /var/aegir/drush/drush
	
	cp /var/aegir/hosting_queued.conf /etc/supervisor/conf.d/
	chown aegir:aegir /var/aegir/hosting_queued.sh
	chmod 700 /var/aegir/hosting_queued.sh
fi

# Stop mariadb, supervisor will start it later and keep it running.
mysqladmin -p$MYSQL_ROOT_PW shutdown

#DPKG_DEBUG=developer apt-get -y install aegir2

echo "Starting supervisor:"
supervisord -c /opt/supervisor.conf -n