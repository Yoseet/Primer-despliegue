# Dockerfile
FROM ubuntu:22.04

# Evitar prompts durante la instalación
ENV DEBIAN_FRONTEND=noninteractive
# Instalar dependencias
RUN apt-get update && apt-get install -y \
apache2 \
php \
libapache2-mod-php \
php-mysql \
mysql-server \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*
# Habilitar módulo rewrite de Apache
RUN a2enmod rewrite
# Copiar aplicación PHP
COPY ./app /var/www/html
# Copiar script de inicialización
COPY init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh
# Exponer puertos
EXPOSE 80 3306
# Comando de inicio
# Dockerfile
FROM ubuntu:22.04

# Evitar prompts durante la instalación
ENV DEBIAN_FRONTEND=noninteractive
# Instalar dependencias
RUN apt-get update && apt-get install -y \
apache2 \
php \
libapache2-mod-php \
php-mysql \
mysql-server \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*
# Habilitar módulo rewrite de Apache
RUN a2enmod rewrite
# Copiar aplicación PHP
COPY ./app /var/www/html
# Copiar script de inicialización
COPY init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh
# Exponer puertos
EXPOSE 80 3306
# Comando de inicio
CMD ["bash", "/usr/local/bin/init.sh"]