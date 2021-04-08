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

COPY srcs ./root/
#Copier tout le contenu de srcs dans le dossier root du container

WORKDIR /root/
#Spécifier dans quel dossier se placer au lancement du container

#CERTIFICAT SSL
RUN mkdir /etc/nginx/ssl
#RUN openssl genrsa -des3 -passout pass:1234 -out /etc/nginx/ssl/localhost.pem -keyout /etc/nginx/ssl/localhost.key
#RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out /etc/nginx/ssl/localhost.pem -keyout /etc/nginx/ssl/localhost.key

#NGINX
RUN mkdir /var/www/localhost
RUN mv ./localhost /etc/nginx/sites-available
RUN chown -R www-data /var/www/*
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/
#RUN nginx -t

#MYSQL
RUN service mysql start

#PHPMYADMIN
RUN mv ./info.php /var/www/localhost
RUN chmod 777 /var/www/localhost/info.php
RUN chown -R www-data:www-data /var/www/localhost
RUN service php7.3-fpm start


#WORDPRESS


EXPOSE 80 443


#ENTRYPOINT ["bash", "start.sh"]
#Executer une commande au lancement du container