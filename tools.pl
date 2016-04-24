#!/usr/bin/env perl
use strict;
use warnings;
use English;
use File::Spec;
use Time::Piece;
use File::Basename;

my @get_url = qw{
    github.com/nsf/gocode
    github.com/motemen/ghq
    github.com/Masterminds/glide
};


my $go_path = "$ENV{HOME}/go";
my $env_go_path = $ENV{GOPATH} || '';

die "unknown GOPATH: $env_go_path\n" if($go_path ne $env_go_path);

for my $url (@get_url){
    my $name = basename($url);
    my $install_cmd = "go get -v -u $url";

    if( which($name) ){
        print "already installed [$name] or $install_cmd\n";
    }
    else {
        print "install [$name].\n$install_cmd\n";
        system 'go','get', '-v', '-u', $url;
    }
}

exit;

sub which {
    my $cmd = shift;
    for my $dir (File::Spec->path){
        my $fullpath = File::Spec->catfile($dir, $cmd);
        return $fullpath if -x $fullpath;
    }
    return;
}

__END__

TODO
$ git config --add ghq.root $GOPATH/src

