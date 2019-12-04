FROM ubuntu:18.04
MAINTAINER Eduard Istvan Sas <eduard.istvan.sas@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

COPY respond.txt /tmp/
COPY docker-entrypoint.sh /usr/local/bin/

RUN rm -f /etc/localtime && ln -s /usr/share/zoneinfo/Europe/Bucharest /etc/localtime \
 && echo "Europe/Bucharest" > /etc/timezone \
 && apt-get update \
 && apt-get -y dist-upgrade \
 && apt-get install -y make php php-gettext php-mbstring php-curl php-gd php-soap apache2 libapache2-mod-php libapache2-mod-perl2 libapache2-mod-perl2-dev php-mysql \
 mysql-client libmojolicious-perl libplack-perl libswitch-perl git\
 && rm -rf /var/www/html/* \
 && a2enmod rewrite \
 && a2enmod perl \
 && a2enmod ssl \
 && a2ensite default-ssl \
 && cd /tmp \
 && git clone https://github.com/OCSInventory-NG/OCSInventory-Server.git ocsserver \
 && git clone https://github.com/OCSInventory-NG/OCSInventory-ocsreports.git ocsserver/ocsreports \
 && cd /tmp/ocsserver \
 && cat ../respond.txt | ./setup.sh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && a2enconf z-ocsinventory-server \
 && a2enconf ocsinventory-reports \
 && phpenmod curl \
 && phpenmod gd \
 && phpenmod soap \
 && cd \
 && rm -rf /tmp/ocsserver \
 && rm -rf /tmp/respond.txt \
 && mkdir  touch /usr/share/ocsinventory-reports/ocsreports/vendor \
 && touch /usr/share/ocsinventory-reports/ocsreports/vendor/autoload.php \
 && chown -R www-data:www-data /var/lib/ocsinventory-reports/ \
 && chown -R www-data:www-data /usr/share/ocsinventory-reports \
 && echo '<?php header("Location:/ocsreports/index.php"); ?>' > /var/www/html/index.php \
 && chmod +x /usr/local/bin/docker-entrypoint.sh

# Apache musthave env vars
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80
EXPOSE 443

CMD ["/usr/local/bin/docker-entrypoint.sh"]
