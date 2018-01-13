About
=====

This generates configuration for buildbot-slave and init scripts to start
each project. This generates one buildbot-slave for each project

Usage
=====

To add project create file <project>.project.in and fill values

* buildmaster_port

    Port on which buildbot master listens for connections from slaves

* password

    password slave will use to log in to master.

* buildmaster_host

    host or ip where buildbot master is

* arch

    Space separated list of architectures project should be tested on.
    If set to 'all' project will be tested on all supported architectures.
    List of architectures can be found at the beginning of *gen-packages.sh*

To add or remove architecture, modify variable *all_archs* in *gen-packages.sh*


Call *make* to generate opkg files. Call *make clan* to clean up directory of
generated files

Contact
=======

Michał Łyszczek <michal.lyszczek@bofc.pl>
