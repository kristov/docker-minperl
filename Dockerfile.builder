FROM perl:5.32.0-buster
MAINTAINER Ad Buster chris.eade@gmail.com

RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm Carton

RUN mkdir build
COPY cpanfile build/cpanfile
COPY cpanfile.snapshot build/cpanfile.snapshot
RUN cd build && carton install
RUN cd build && rm -rf local/cache
COPY finder.pl build/finder.pl
RUN cd build && perl finder.pl local
RUN cd build && mkdir -p usr/local/lib/perl5/ && cp -r /usr/local/lib/perl5/5.32.0 usr/local/lib/perl5/
RUN cd build && find . -name "*.pod" | xargs -i{} rm {}
