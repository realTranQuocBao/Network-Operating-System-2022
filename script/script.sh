## Install fail2ban and enable firewall
apt-get update; apt-get upgrade -y; apt-get install -y fail2ban ufw;

# SSH, HTTP and HTTPS
ufw allow 22
ufw allow 80
ufw allow 443

# Skip the following 3 lines if you do not plan on using FTP
ufw allow 21 
ufw allow 50000:50099/tcp 
ufw allow out 20/tcp

# And lastly we activate UFW
ufw --force enable

# Here we choose the port range 50000->50099 in order to allow passive FTP connections.

## Add some PPAs to stay current
apt-get install -y software-properties-common
apt-add-repository ppa:ondrej/apache2 -y
apt-add-repository ppa:ondrej/php -y

# Set up MariaDB repositories
apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://mirrors.dotsrc.org/mariadb/repo/10.6/ubuntu focal main'

## Install base packages
apt-get update; apt-get install -y build-essential curl nano wget lftp unzip bzip2 arj nomarch lzop htop openssl gcc git binutils libmcrypt4 libpcre3-dev make python3 python3-pip supervisor unattended-upgrades whois zsh imagemagick uuid-runtime net-tools zip dirmngr apt-transport-https

## Set the timezone to UTC
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

## Set SSH to KeepAlive
# If you want the SSH Daemon to keep your connections alive, you can run the following commands:
sed -i "s/#TCPKeepAlive yes/TCPKeepAlive yes/" /etc/ssh/sshd_config
sed -i "s/#ClientAliveInterval 0/ClientAliveInterval 60/" /etc/ssh/sshd_config
sed -i "s/#ClientAliveCountMax 3/ClientAliveCountMax 3/" /etc/ssh/sshd_config

## Install PHP7.4 and common PHP packages
apt-get install -y php7.4-cli php7.4-dev php7.4-pgsql php7.4-sqlite3 php7.4-gd php7.4-curl php7.4-memcached php7.4-imap php7.4-mysql php7.4-mbstring php7.4-xml php7.4-imagick php7.4-zip php7.4-bcmath php7.4-soap php7.4-intl php7.4-readline php7.4-common php7.4-pspell php7.4-tidy php7.4-xmlrpc php7.4-xsl php7.4-opcache php7.4-apcu

## Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

## Install and configure Memcached
apt-get install -y memcached
sed -i 's/-l 0.0.0.0/-l 127.0.0.1/' /etc/memcached.conf
systemctl restart memcached

## Update PHP CLI configuration
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.4/cli/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.4/cli/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.4/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.4/cli/php.ini

## Configure sessions directory permissions
chmod 733 /var/lib/php/sessions
chmod +t /var/lib/php/sessions

## Install Apache and PHP-FPM
apt-get install -y apache2 apache2-utils php7.4-fpm

## Tweak PHP-FPM settings
# Please note: We are suppressing PHP error output here by setting these options to production values
sed -i "s/error_reporting = .*/error_reporting = E_ALL \& ~E_NOTICE \& ~E_STRICT \& ~E_DEPRECATED/" /etc/php/7.4/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = Off/" /etc/php/7.4/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.4/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 256M/" /etc/php/7.4/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 256M/" /etc/php/7.4/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.4/fpm/php.ini