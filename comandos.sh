# BUSCAR REPO
# rpm -qa |grep -i repo-name

# ELIMINAR REPO
# # rpm -qf /etc/yum.repos.d/rpmforge.repo
# rpmforge-release-0.5.1-1.el5.rf
# # yum remove rpmforge-release
# yum --showduplicates list php-gd
# # regenerar tarjeta de red cuando se clona VM
# cd /etc/udev/rules.d
# cp 70-persistent-net.rules /root/
# rm 70-persistent-net.rules
# reboot
# # cabia MAC de ETH1 A ETH0
# vim /etc/sysconfig/networking-scripts/ifcfg-eth0
# service network restart
# version de distro
# cat /etc/issue
#cat /etc/redhat-release
#cat /etc/debian_version
#uname -a
## montar
vi /etc/init/vagrant-mounted.conf
start on vagrant-mounted
exec sudo service httpd start

# [MAKE]
yum install make gcc automake zlib-devel bison cmake libtool wget gcc-c++ unzip ncurses-devel openssl-devel pcre-devel libxml2-devel curl-devel gd-devel libxslt-devel

#[LibMCrypt]
cd /usr/local/src
curl --remote-name --location http://downloads.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
tar -xzvf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure --prefix=/usr/local/libmcrypt-2.5.8
make
make install
ln -s libmcrypt-2.5.8 /usr/local/libmcrypt

#[IPTABLES]
#vi /etc/sysconfig/iptables
#-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
#service iptables restart
iptables -I INPUT 5 -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
iptables-save > /etc/sysconfig/iptables

#[APACHE]
cd /usr/local/src/
wget http://archive.apache.org/dist/httpd/httpd-2.2.27.tar.gz
tar zxvf httpd-2.2.27.tar.gz
cd httpd-2.2.27
#./configure --prefix=/etc/httpd --exec-prefix=/etc/httpd --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc/httpd/conf --enable-so --enable-dav --enable-dav-fs --enable-dav-lock --enable-suexec --enable-deflate --enable-unique-id --enable-mods-static=most --enable-reqtimeout --with-mpm=prefork --with-suexec-caller=apache --with-suexec-docroot=/ --with-suexec-gidmin=100 --with-suexec-logfile=/var/log/httpd/suexec_log --with-suexec-uidmin=100 --with-suexec-userdir=public_html --with-suexec-bin=/usr/sbin/suexec --with-included-apr --with-pcre=/usr --includedir=/usr/include/apache --libexecdir=/usr/lib/apache --datadir=/var/www --localstatedir=/var --enable-logio --enable-ssl --enable-rewrite --enable-proxy --enable-expires --with-ssl=/usr --enable-headers
./configure --enable-so --enable-mods-shared=most
make
make install
ln -s /usr/local/apache2/bin/apachectl /etc/init.d/httpd
#cd /etc/rc3.d/
#ln -s ../init.d/httpd S98httpd
ln -s /etc/init.d/httpd /etc/rc3.d/S98httpd
# vi /usr/local/apache2/conf/httpd.conf
# ServerName 127.0.0.1
# AllowOverride All
sed -i 's/#ServerName .*/ServerName 127.0.0.1/' /usr/local/apache2/conf/httpd.conf
sed -i 's/    DirectoryIndex index.html.*/    DirectoryIndex index.php index.html/' /usr/local/apache2/conf/httpd.conf
service httpd start

#[MYSQL]
cd /usr/local/src/
wget http://dev.mysql.com/get/Downloads/MySQL-5.5/mysql-5.5.40.tar.gz
tar zxvf mysql-5.5.40.tar.gz
cd mysql-5.5.40
groupadd mysql
useradd -g mysql mysql
# cmake .  -DMYSQL_UNIX_ADDR=/tmp/mysql.sock
cmake .
make
make install
sed -i 's/socket=.*/socket\=\/tmp\/mysql.sock/' /etc/my.cnf
cd /usr/local/mysql/
#change owner and group
chown -R mysql:mysql .
scripts/mysql_install_db --user=mysql --datadir=/var/lib/mysql
#add service command
cp support-files/mysql.server /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on
service mysqld start
./bin/mysqladmin -u root password '123456' 
#./bin/mysqladmin -u root -h change.this.hostname password '123456'
#bin/mysql_secure_installation
netstat -tulpn | grep 3306

#[PHP]
cd /usr/local/src/
wget http://us2.php.net/get/php-5.3.29.tar.gz/from/this/mirror -O php-5.3.29.tar.gz
tar zxvf php-5.3.29.tar.gz
cd php-5.3.29
./configure --with-apxs2=/usr/local/apache2/bin/apxs --with-curl=/usr --with-gd --with-gettext --with-jpeg-dir=/usr --with-freetype-dir=/usr --with-kerberos --with-openssl --with-mcrypt=/usr/local/libmcrypt-2.5.8 --with-mhash --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pcre-regex --with-pear --with-png-dir=/usr --with-xsl --with-zlib --with-zlib-dir=/usr --with-iconv --enable-bcmath --enable-calendar --enable-exif --enable-ftp --enable-gd-native-ttf --enable-soap --enable-sockets --enable-mbstring --enable-zip --enable-wddx --with-pdo-mysql=/usr/local/mysql --enable-shared
make
make install
#libtool --finish /root/php-5.3.29/libs
cp php.ini-production /usr/local/lib/php.ini
sed -i 's/;date.timezone =.*/  date.timezone \= "America\/Lima"/' /usr/local/lib/php.ini
echo "<?php phpinfo();?>" > /usr/local/apache2/htdocs/index.php
echo "AddType application/x-httpd-php .php" >> /usr/local/apache2/conf/extra/httpd-php.conf
echo "Include conf/extra/httpd-php.conf" >> /usr/local/apache2/conf/httpd.conf
/etc/init.d/httpd restart

#[phpMyAdmin]
cd /usr/local/src/
wget http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/4.2.12/phpMyAdmin-4.2.12-all-languages.tar.gz
tar zxvf phpMyAdmin-4.2.12-all-languages.tar.gz
mv phpMyAdmin-4.2.12-all-languages /usr/local/phpmyadmin
echo "Alias /phpmyadmin \"/usr/local/phpmyadmin/\"
<Directory \"/usr/local/phpmyadmin/\">
    Options Indexes FollowSymLinks MultiViews
    AllowOverride all
        Order Allow,Deny
    Allow from all
</Directory>" >> /usr/local/apache2/conf/extra/httpd-phpmyadmin.conf
echo "Include conf/extra/httpd-phpmyadmin.conf" >> /usr/local/apache2/conf/httpd.conf
/etc/init.d/httpd restart

#[Openssl]
# En apache compilar
./configure --enable-ssl --enable-so
make
make install
vi /usr/local/apache2/conf/httpd.conf
Include conf/extra/httpd-ssl.conf

vi /usr/local/apache2/conf/extra/httpd-ssl.conf

# egrep 'server.crt|server.key' httpd-ssl.conf
SSLCertificateFile "/usr/local/apache2/conf/server.crt"
SSLCertificateKeyFile "/usr/local/apache2/conf/server.key"

cd ~
openssl genrsa -des3 -out server.key 1024

openssl req -new -key server.key -out server.csr
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
cd ~
cp server.key /usr/local/apache2/conf/
cp server.crt /usr/local/apache2/conf/
/usr/local/apache2/bin/apachectl start

Apache/2.2.17 mod_ssl/2.2.17 (Pass Phrase Dialog)
Some of your private key files are encrypted for security reasons.
In order to read them you have to provide the pass phrases.
Server www.example.com:443 (RSA)
Enter pass phrase:
OK: Pass Phrase Dialog successful.
# para que no pida contraseña
cd /usr/local/apache2/
vi ssl.sh
#!/bin/bash
echo "pass"
chmod +x ssl.sh
vi conf/extra/httpd-ssl.conf
SSLPassPhraseDialog  exec:/usr/local/apache2/ssl.sh
 
# abrimos el puerto 443
iptables -I INPUT 5 -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
iptables-save > /etc/sysconfig/iptables

#[samba] 
yum install samba samba-client samba-common
chkconfig smb on
chkconfig nmb on
service smb restart
service nmb restart
iptables -I INPUT 4 -m state --state NEW -m udp -p udp --dport 137 -j ACCEPT
iptables -I INPUT 5 -m state --state NEW -m udp -p udp --dport 138 -j ACCEPT
iptables -I INPUT 6 -m state --state NEW -m tcp -p tcp --dport 139 -j ACCEPT
iptables-save > /etc/sysconfig/iptables
useradd smbuser 
groupadd smbgrp 
usermod -a -G smbgrp smbuser 
smbpasswd -a smbuser

vi /etc/samba/smb.conf
[web]
path = /usr/local/apache2/htdocs
available = yes
valid users = smbuser
read only = no
browseable = yes
public = yes
writable = yes
write list = smbuser
create mode = 0660
directory mode = 0770

#compartir de window a linux
yum -y install cifs-utils
# mount -t cifs //name-pc/dir-shared /media/shared -o user=userpc,password=xxxxxx,file_mode=0777,dir_mode=0777
vi /etc/fstab
//name-pc-o-ip/dir-shared /media/shared cifs user=userpc,password=xxxxxx,nounix,noserverino,defaults,users,auto,file_mode=0777,dir_mode=0777

# other
visudo
%admin ALL=(ALL) NOPASSWD:ALL
vi /etc/sysconfig/network
HOSTNAME=namedomain
vi /etc/hosts
IP   namedomain  namedomain.localdomain

#[APC]
cd /usr/local/src/
wget http://pecl.php.net/get/APC
tar -xvf APC
cd APC-X.X.X (replace with your downloaded version)
phpize
./configure
make && make install

vi /usr/local/lib/php.ini
extension=apc.so
apc.enabled=1
apc.shm_size=1000M
apc.ttl=7200
apc.user_ttl=7200
apc.enable_cli=1
apc.max_file_size=5M

#[CHANGE DATE]
ls /usr/share/zoneinfo/America/
cp /usr/share/zoneinfo/America/Lima /etc/localtime

#[NTP SINCRONIZAR TIME]
sudo yum install ntp
sudo /sbin/chkconfig ntpd on
sudo /etc/init.d/ntpd start
iptables -I INPUT -p udp --dport 123 -j ACCEPT
iptables -I OUTPUT -p udp --sport 123 -j ACCEPT
iptables-save > /etc/sysconfig/iptables
/etc/init.d/iptables restart

#[MYSQL REMOTE ACCESS]
mysql -u root -p
GRANT ALL PRIVILEGES on *.* TO 'root'@'%' IDENTIFIED BY 'PASSWORD' WITH GRANT OPTION;
FLUSH PRIVILEGES;

iptables -I INPUT 5 -m state --state NEW -m tcp -p tcp --dport 3306 -j ACCEPT
iptables-save > /etc/sysconfig/iptables
# SI NO FUNCIONA 
vi /etc/my.cnf
bind-address    = * # or IP
# skip-networking
