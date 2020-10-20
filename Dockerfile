FROM scratch
MAINTAINER Bob Geldof chris.eade@gmail.com
ADD minperl.tar.xz /
COPY app.psgi /
COPY hello.html /
CMD ["/usr/bin/perl", "-Ilocal/lib/perl5", "local/bin/plackup", "app.psgi"]
