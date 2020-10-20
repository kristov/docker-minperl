# Docker minperl

My attempt to get a super bare-bones container for running plack/starman Perl applications. It weighs in at about 67MB, so while lighter than a full OS image is still heavier than I would prefer. How it works:

## Building

It uses a builder container based off `perl:5.32.0-buster`. This installs carton, copies over the `cpanfile` and builds a local lib for the application. It then uses a Perl script called `finder.pl` to discover the required shared `.so` files (XS) needed by the Perl interpreter and and base Perl modules. Finaly it bundles the minimal environment into a tarball and uses that in a second stage `Dockerfile` as a base image.

## How to use it

* Customise `cpanfile` to suit dependency needs.
* Modify `Dockerfile` change `CMD` to what you need and copy any required files over.
* Run ./build.sh

    $ docker run -t minperl
    HTTP::Server::PSGI: Accepting connections at http://0:5000/

## Why?

Because I wanted to know if it was possible. The builder container is needed because installing Perl modules requires a C compiler, and that essentially implies an OS image. However as long as the scratch image has the required shared object files that whole build environment is not really needed.
