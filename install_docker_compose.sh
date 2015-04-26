#!/bin/sh
set -e

if [ ! -x /usr/local/bin/docker-compose ]; then
  curl -s -L -o /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m`
  chmod +x /usr/local/bin/docker-compose
fi

if [ ! -f /etc/init/docker-compose.conf ]; then
  cat <<'EOF' | sudo sh -c 'cat > /etc/init/docker-compose.conf'
# docker-compose - defining and running complex applications with Docker
#
# With Compose, you define a multi-container application in a single file,
# then spin your application up in a single command which does everything
# that needs to be done to get it running.

description     "Docker Compose"

start on (local-filesystems and net-device-up IFACE!=lo and started docker)
stop on runlevel [!2345]

respawn
respawn limit 10 5
umask 022

pre-start script
    test -x /usr/local/bin/docker-compose || { stop; exit 0; }
    test -f /vagrant/dockerfiles/docker-compose.yml || { stop; exit 0; }
end script

chdir /vagrant/dockerfiles
exec /usr/local/bin/docker-compose up
EOF

  initctl reload-configuration
  initctl start docker-compose
fi
