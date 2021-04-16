#Build le Docker (Ajouter sudo au début sur la VM):
#docker build -t 'name' .
#Lancer le Docker (Ajouter sudo au début sur la VM):
#docker run -it -p 80:80 -p 443:443 'name'

#Definir Debian Buster comme image de base
FROM debian:buster-slim

#Installer tous les paquets qu'il faut
RUN apt-get -y update && apt-get -y install mariadb-server \
											wget \
											unzip \
											php \
											php-cli \
											php-cgi \
											php-mbstring \
											php-fpm \
											php-mysql \
											nginx \
											libnss3-tools

#Copier les fichiers de configuration
COPY srcs/wordpress /etc/nginx/sites-available
COPY srcs/phpmyadmin /etc/nginx/sites-available

#CERTIFICAT SSL
RUN mkdir /etc/nginx/ssl
RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -subj '/C=FR/ST=75/L=Paris/O=42/CN=ericard'\
	 -keyout /etc/nginx/ssl/localhost.key -out /etc/nginx/ssl/localhost.crt

#NGINX
RUN rm /etc/nginx/sites-available/default
COPY srcs/default /etc/nginx/sites-available
RUN nginx -t

#MYSQL
COPY srcs/init.sql /root/
RUN service mysql start && mysql -uroot -proot mysql < "./root/init.sql"

#PHPMYADMIN
RUN rm /etc/php/7.3/fpm/php.ini
COPY srcs/php.ini /etc/php/7.3/fpm/php.ini
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.zip
RUN unzip phpMyAdmin-4.9.0.1-all-languages.zip
RUN mv phpMyAdmin-4.9.0.1-all-languages phpmyadmin
RUN mv phpmyadmin /var/www/html
RUN rm phpMyAdmin-4.9.0.1-all-languages.zip
RUN chmod -R 755 /var/www/html/phpmyadmin/

#WORDPRESS
RUN wget http://fr.wordpress.org/latest-fr_FR.tar.gz
RUN tar -xzvf latest-fr_FR.tar.gz && rm latest-fr_FR.tar.gz
RUN mv wordpress /var/www/html
RUN chmod -R 755 /var/www/html/wordpress/
COPY srcs/wp-config.php /var/www/html/wordpress

#Avoir l'index
RUN rm /var/www/html/index.nginx-debian.html

#Ouvrir les ports
EXPOSE 80 443

#Lancer les services
CMD service mysql start && service nginx start && service php7.3-fpm start && sleep infinity