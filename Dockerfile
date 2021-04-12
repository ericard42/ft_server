FROM debian:buster-slim
#Definir Debian Buster comme image de base

RUN apt-get -y update && apt-get -y install mariadb-server \
											wget \
											php \
											php-cli \
											php-cgi \
											php-mbstring \
											php-fpm \
											php-mysql \
											nginx \
											libnss3-tools
#Installer tous les paquets qu'il faut

COPY srcs/wordpress /etc/nginx/sites-available
COPY srcs/phpmyadmin /etc/nginx/sites-available
#Copier tout le contenu de srcs dans le dossier root du container

WORKDIR /root/
#Spécifier dans quel dossier se placer au lancement du container

#CERTIFICAT SSL
RUN mkdir /etc/nginx/ssl
RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -subj '/C=FR/ST=75/L=Paris/O=42/CN=ericard'\
	 -keyout /etc/nginx/ssl/localhost.key -out /etc/nginx/ssl/localhost.crt

#NGINX
RUN rm /etc/nginx/sites-available/default
COPY srcs/default /etc/nginx/sites-available
#RUN chown -R www-data /var/www/*
#RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/

#MYSQL
COPY srcs/init.sql /root/
RUN service mysql start && mysql -uroot -proot mysql < "./init.sql"

#PHPMYADMIN
COPY srcs/test.html /var/www/html/
RUN chown -R www-data:www-data /var/www/html

#WORDPRESS
RUN wget http://fr.wordpress.org/latest-fr_FR.tar.gz
RUN tar -xzvf latest-fr_FR.tar.gz && rm latest-fr_FR.tar.gz
RUN mv wordpress /var/www/html

RUN chmod -R 755 /var/www/html/wordpress/

COPY srcs/info.php /var/www/html/wordpress
RUN chmod 777 /var/www/html/wordpress/info.php
#RUN chmod -R 755 /var/www/html/phpmyadmin/

EXPOSE 80 443

CMD service mysql start && service nginx start && service php7.3-fpm start
#Executer une commande au lancement du container