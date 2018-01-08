#!/bin/sh

version="0.0.3"

all_archs="
    i686-builder-freebsd
    x86_64-builder-linux-musl
    i686-builder-linux-musl
    x86_64-builder-linux-uclibc
    i686-builder-linux-uclibc
    x86_64-builder-linux-gnu
    mips-builder-linux-gnu
    nios2-builder-linux-gnu
    aarch64-builder-linux-gnu
    armv5te926-builder-linux-gnueabihf
    armv6j1136-builder-linux-gnueabihf
    armv7a15-builder-linux-gnueabihf
    armv7a9-builder-linux-gnueabihf
    i686-builder-linux-gnu"

rm -rf tmp

for p in *.project.in
do
    source "./${p}"
    name=`echo ${p} | cut -f1 -d.`

    if [ "${arch}" = "all" ]
    then
        arch="${all_archs}"
    fi

    for a in ${arch}
    do
        mkdir -p tmp/${a}/var/lib/buildbot-${name}
        mkdir -p tmp/${a}/etc/init.d
        ln -fs /etc/init.d/S99-buildbot tmp/${a}/etc/init.d/S99-buildbot.${name}
        cd tmp/${a}/var/lib/buildbot-${name}
        cp ../../../../../buildbot-slave.tac.template buildbot.tac

        sed -i "s/\${BUILDMASTER_PORT}/${buildmaster_port}/" buildbot.tac
        sed -i "s/\${WORKER_NAME}/${a}/" buildbot.tac
        sed -i "s/\${PASSWORD}/${password}/" buildbot.tac
        sed -i "s/\${BUILDMASTER_HOST}/${buildmaster_host}/" buildbot.tac

        cd -
    done
done


for a in ${all_archs}
do
    mkdir -p tmp/${a}/CONTROL
    cp control.template tmp/${a}/CONTROL/control
    cp S99-buildbot.in tmp/${a}/etc/init.d/S99-buildbot
    chmod 755 tmp/${a}/etc/init.d/S99-buildbot
    echo "#!/bin/sh" > tmp/${a}/CONTROL/postinst
    chmod 755 tmp/${a}/CONTROL/postinst

    cd tmp/${a}/var/lib
    for d in `ls -1`
    do
        echo "chown -R buildbot:buildbot /var/lib/${d}" >> ../../CONTROL/postinst
    done
    cd -

    sed -i "s/\${TARGET}/${a}/" tmp/${a}/etc/init.d/S99-buildbot
    sed -i "s/\${VERSION}/${version}/" tmp/${a}/CONTROL/control
    ###
    # opkg doesn't support _ in pacakge names, change it to -
    #
    target=`echo ${a} | sed 's/_/-/'`
    sed -i "s/\${TARGET}/${target}/" tmp/${a}/CONTROL/control

    opkg-build -O -o root -g root tmp/${a} .
done
