#!/usr/bin/perl

use strict;
use warnings;
use File::Basename qw(dirname);

my @dirs = $ARGV[0];
push @dirs, @INC;

my $perl = "/usr/local/bin/perl";

sub build_deps_dir {
    my ($deps, $dir) = @_;
    if (!-e $dir) {
        return;
    }
    my @sos = `find $dir -name "*.so"`;
    for my $so (@sos) {
        chomp $so;
        build_deps_file($deps, $so);
    }
}

sub build_deps_file {
    my ($deps, $file) = @_;
    my @libs = `ldd $file`;
    for my $lib (@libs) {
        chomp $lib;
        if ($lib =~ m{\s+([a-z0-9\-\.]+)\s=>\s([a-z0-9/_\-\.]+)}) {
            $deps->{$1} = $2;
            next;
        }
        if ($lib =~ m{\s+([a-z0-9/\-\.]+)\s}) {
            $deps->{$1} = "absolute";
            next;
        }
    }
}

my %deps;
build_deps_file(\%deps, $perl);
for my $dir (@dirs) {
    build_deps_dir(\%deps, $dir);
}
delete $deps{'linux-vdso.so.1'};

my %links;
for my $dep (sort {$a cmp $b} keys %deps) {
    my $file = $deps{$dep};
    if ($file eq 'absolute') {
        $file = $dep;
    }
    if (my $real = readlink($file)) {
        my $target;
        if ($real =~ m{^/}) {
            $target = $real;
        }
        else {
            my $dir = dirname($file);
            $target = "$dir/$real";
        }
        $links{$file} = {
            copy => $target,
            link => $file,
        };
    }
    else {
        $links{$file} = {
            copy => $file,
            link => undef,
        };
    }
}
for my $lib (keys %links) {
    my $copy = $links{$lib}->{copy};
    my $dir = dirname($copy);
    $dir =~ s|^/||;
    my $dest = $copy;
    $dest =~ s|^/||;
    `mkdir -p $dir`;
    print "$copy $dest\n";
    `cp $copy $dest`;
    if (my $link = $links{$lib}->{link}) {
        my $dir = dirname($link);
        $dir =~ s|^/||;
        `mkdir -p $dir`;
        $link =~ s|^/||;
        `ln -s /$dest $link`;
    }
}
`mkdir -p usr/bin`;
`cp /usr/local/bin/perl usr/bin`;
