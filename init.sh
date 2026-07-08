#!/bin/bash
set -e

MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-rootpass}"
rm -f /var/www/html/index.html
service mysql start
service apache2 start

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

echo "Esperando a que MySQL esté disponible..."
for i in $(seq 1 30); do
    if mysqladmin ping -h 127.0.0.1 --silent; then
        break
    fi
    sleep 1
done

if ! mysqladmin ping -h 127.0.0.1 --silent; then
    echo "MySQL no respondió a tiempo."
    exit 1
fi

if mysql -uroot -e "SELECT 1" >/dev/null 2>&1; then
    mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}'; FLUSH PRIVILEGES;"
else
    echo "No se pudo autenticar como root con el socket local."
    exit 1
fi

mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS biblioteca_db;"
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS 'biblioteca_user'@'%' IDENTIFIED WITH mysql_native_password BY 'secret123';"
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON biblioteca_db.* TO 'biblioteca_user'@'%';"
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" biblioteca_db <<'SQL'
CREATE TABLE IF NOT EXISTS libros (
  id INT AUTO_INCREMENT PRIMARY KEY,
  titulo VARCHAR(100) NOT NULL,
  autor VARCHAR(100) NOT NULL,
  anio_publicacion INT
);

INSERT INTO libros (titulo, autor, anio_publicacion) VALUES
  ('Cien años de soledad', 'Gabriel García Márquez', 1967),
  ('El principito', 'Antoine de Saint-Exupéry', 1943),
  ('1984', 'George Orwell', 1949),
  ('Don Quijote de la Mancha', 'Miguel de Cervantes', 1605)
ON DUPLICATE KEY UPDATE titulo = VALUES(titulo);
SQL

tail -f /dev/null