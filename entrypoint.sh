#!/bin/bash
export JAIL=/jail

function create_chroot {
    # Create jail
    echo "Creating jail.."
    mkdir -p $JAIL

    # Create devices
    echo "Creating devices.."
    mkdir -p $JAIL/dev
    mknod -m 0666 $JAIL/dev/null c 1 3
    mknod -m 0666 $JAIL/dev/random c 1 8
    mknod -m 0444 $JAIL/dev/urandom c 1 9

    # Create directories
    echo "Creating directories.."
    mkdir -p $JAIL/{etc,bin,usr,var}
    mkdir -p $JAIL/usr/{lib,sbin,bin}
    mkdir -p $JAIL/{run,tmp}
    mkdir -p $JAIL/var/run
    mkdir -p $JAIL/usr/share/zoneinfo
    mkdir -p $JAIL/var/tmxweb

    # Check if 64-bit system
    if [ $(uname -m) = "x86_64" ]; then
        mkdir -p $JAIL/lib/x86_64-linux-gnu
        cd $JAIL; ln -s usr/lib lib64
        cd $JAIL/usr; ln -s lib lib64
    else
        cd $JAIL; ln -s usr/lib lib
    fi

    echo "Copying configurations /etc.."
    cp -rfvL /etc/{services,localtime,nsswitch.conf,protocols,hosts,ld.so.cache,ld.so.conf,resolv.conf,host.conf} $JAIL/etc

    echo "Copying timezone information.."
    cp -R /usr/share/zoneinfo $JAIL/usr/share
}

function create_directory_structure {
    echo "Creating directory structure.."
    mkdir -p $JAIL/var/tmxweb/tmp
    chmod 775 $JAIL/var/tmxweb/tmp
    chown -R www-data:www-data $JAIL/var/tmxweb
}

function boot {
    echo "Starting FPM.."
    /etc/init.d/php7.1-fpm start
    echo "Starting NGINX..";
    nginx -g "daemon off;"
}

create_chroot
create_directory_structure
boot
echo "TMX Webserver running at http://0.0.0.0:8080"
