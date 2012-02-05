== Coworking MetaData

This repository contains the metadata files that are used to drive
applications (like maps and such) that do useful things for the Coworking
community at large.

The primary files are:

* `sites.yaml` - A simple list of the URLs of coworking sites.
* `metadata.yaml` - Master file of all the coworking metadata; in YAML format.
* `metadata.json` - Master file of all the coworking metadata; in JSON format.

These files may be used by anybody for any purpose. Typically they are used to
generate maps, with site locations.

== Spider Prerequisites

This repository uses a Perl script to spider the urls in `sites.yaml` and
generate the YAML and JSON files.

You don't need to worry about this unless you are regenerating the metadata
yourself. In that case you will likely need to install a few Perl modules. The
easiest way to install Perl modules is with `cpanm`
( http://search.cpan.org/dist/App-cpanminus/lib/App/cpanminus.pm ). You can get
`cpanm` by running this command.

    curl -L http://cpanmin.us | perl - --sudo App::cpanminus

Then you can install the Perl modules like so:

    cpanm --sudo YAML::XS
    cpanm --sudo JSON::XS
    cpanm --sudo IO::All
    cpanm --sudo IO::All::LWP

To run the scripts that spider the web and create the metadata files, run:

    make clean all

