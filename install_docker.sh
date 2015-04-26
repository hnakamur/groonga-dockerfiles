#!/bin/sh
set -e

if [ ! -x /usr/local/bin/docker ]; then
  sudo curl -s -L -o /usr/local/bin/docker https://get.docker.com/builds/Linux/x86_64/docker-latest
  sudo chmod +x /usr/local/bin/docker

  cat <<'EOF' | sudo sh -c 'cat > /etc/default/docker'
# Docker Upstart and SysVinit configuration file

# Customize location of Docker binary (especially for development testing).
DOCKER="/usr/local/bin/docker"

# Use DOCKER_OPTS to modify the daemon startup options.
#DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4"

# If you need Docker to use an HTTP proxy, it can also be specified here.
#export http_proxy="http://127.0.0.1:3128/"

# This is also a handy place to tweak where Docker's temporary files go.
#export TMPDIR="/mnt/bigdrive/docker-tmp"
EOF

  cat <<'EOF' | sudo sh -c 'cat > /etc/init/docker.conf'
description "Docker daemon"

start on (local-filesystems and net-device-up IFACE!=lo)
stop on runlevel [!2345]
limit nofile 524288 1048576
limit nproc 524288 1048576

respawn

pre-start script
	# see also https://github.com/tianon/cgroupfs-mount/blob/master/cgroupfs-mount
	if grep -v '^#' /etc/fstab | grep -q cgroup \
		|| [ ! -e /proc/cgroups ] \
		|| [ ! -d /sys/fs/cgroup ]; then
		exit 0
	fi
	if ! mountpoint -q /sys/fs/cgroup; then
		mount -t tmpfs -o uid=0,gid=0,mode=0755 cgroup /sys/fs/cgroup
	fi
	(
		cd /sys/fs/cgroup
		for sys in $(awk '!/^#/ { if ($4 == 1) print $1 }' /proc/cgroups); do
			mkdir -p $sys
			if ! mountpoint -q $sys; then
				if ! mount -n -t cgroup -o $sys cgroup $sys; then
					rmdir $sys || true
				fi
			fi
		done
	)
end script

script
	# modify these in /etc/default/$UPSTART_JOB (/etc/default/docker)
	DOCKER=/usr/bin/$UPSTART_JOB
	DOCKER_OPTS=
	if [ -f /etc/default/$UPSTART_JOB ]; then
		. /etc/default/$UPSTART_JOB
	fi
	exec "$DOCKER" -d $DOCKER_OPTS
end script
EOF

  initctl reload-configuration
  initctl start docker
fi
