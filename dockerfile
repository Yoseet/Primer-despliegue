FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    apache2 \
    php \
    libapache2-mod-php \
    php-mysql \
    mysql-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite

# Elimina TODO el contenido por defecto de Apache
RUN rm -rf /var/www/html/*

# Copia tu aplicación
COPY app/ /var/www/html/

# Copia el script
COPY init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

EXPOSE 80 3306

CMD ["bash", "/usr/local/bin/init.sh"]