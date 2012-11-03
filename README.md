# Travis CI Base Box Definitions #

These definitions are used to build base Vagrant boxes Travis CI developers use.


## Getting Started

    bundle install --binstubs

to install dependencies. Then

    ./bin/veewee vbox build oneiric32

or

    ./bin/veewee vbox build precise64

to build the box you need. To export it, run

    ./bin/vagrant basebox export 'precise32'

and so on.


## License & copyright information ##

See LICENSE file.

Copyright (c) 2011-2012 [Travis CI development team](https://github.com/travis-ci).
