#!/bin/sh

version="0.0.8"

all_hosts="
    kurwik
    kurwidev"

all_archs="
    i686-builder-minix
    x86_64-builder-dragonfly
    x86_64-builder-solaris
    i686-builder-netbsd
    i686-builder-openbsd
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
    i686-builder-linux-gnu
    x86_64-builder-debian9
    x86_64-builder-debian8
    x86_64-builder-ubuntu1804
    x86_64-builder-ubuntu1604
    x86_64-builder-centos7
    x86_64-builder-fedora30
    x86_64-builder-fedora29
    x86_64-builder-fedora28
    x86_64-builder-mint19
    x86_64-builder-mint18
    x86_64-builder-opensuse15
    x86_64-builder-rhel7
    x86_64-builder-slackware142
    x86_64-builder-slackware141"

rm -rf tmp

for p in *.project.in
do
    source "./${p}"
    name=`echo ${p} | cut -f1 -d.`

    if [ "${arch}" = "all" ]
    then
        arch="${all_archs}"
    fi

    for h in ${all_hosts}
    do
        for a in ${arch}
        do
            a="$(echo ${a} | sed "s/builder/${h}/")"
            echo "generating buildbot.tac for ${a}"

            mkdir -p tmp/${a}/var/lib/buildbot-${name}
            mkdir -p tmp/${a}/etc/init.d
            ln -fs /etc/init.d/S99-buildbot tmp/${a}/etc/init.d/S99-buildbot.${name}
            cd tmp/${a}/var/lib/buildbot-${name}
            cp ../../../../../buildbot-slave.tac.template buildbot.tac

            sed -i "s/\${BUILDMASTER_PORT}/${buildmaster_port}/" buildbot.tac
            sed -i "s/\${WORKER_NAME}/${a}/" buildbot.tac
            sed -i "s/\${PASSWORD}/${password}/" buildbot.tac
            sed -i "s/\${BUILDMASTER_HOST}/${buildmaster_host}/" buildbot.tac

            cd - > /dev/null
        done
    done
done


for h in ${all_hosts}
do
    for a in ${all_archs}
    do
        gcc="${a}"
        a="$(echo ${a} | sed "s/builder/${h}/")"
        echo "generating opkg for ${a}"

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
        cd - > /dev/null

        sed -i "s/\${TARGET}/${gcc}/" tmp/${a}/etc/init.d/S99-buildbot
        sed -i "s/\${VERSION}/${version}/" tmp/${a}/CONTROL/control
        ###
        # opkg doesn't support _ in pacakge names, change it to -
        #
        target=`echo ${a} | sed 's/_/-/'`
        sed -i "s/\${TARGET}/${target}/" tmp/${a}/CONTROL/control

        opkg-build -O -o root -g root tmp/${a} .
    done
done
