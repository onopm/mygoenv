#!/usr/bin/env perl
use strict;
use warnings;
use English;
use File::Spec;
use File::Basename;
use Term::ANSIColor;

#my $go1_6_src = 'https://storage.googleapis.com/golang/go1.6.src.tar.gz';
#my $go1_5_src = 'https://storage.googleapis.com/golang/go1.5.3.src.tar.gz';
#my $go1_4_src = 'https://storage.googleapis.com/golang/go1.4.3.src.tar.gz';

## URL github
my $go1_6_src = 'https://github.com/golang/go/archive/go1.6.2.tar.gz';
my $go1_4_src = 'https://github.com/golang/go/archive/go1.4.3.tar.gz';

my $go_install_version = go_version($go1_6_src); # go1.6

my $env_home = $ENV{HOME};
my $go_install_dir = "$env_home/local/$go_install_version";

print "Go install => $go_install_dir\n"; 
if(-d $go_install_dir){
    print "already exists go_install_dir\n";
    print_go_env();
    exit;
}

# build go 1.4
my $work_dir = $ENV{PWD};
my $go14_install_dir = "$work_dir/" . go_version($go1_4_src);
if(!-d $go14_install_dir){
    print "download $go1_4_src\n";
    my $tarball = download($go1_4_src);
    print "tarball $ENV{PWD}/$tarball\n";

    print "build go1.4.3 start.\n";
    go_build($tarball, $go14_install_dir);
    print "build go1.4.3 end. PATH=$go14_install_dir/bin\n";
    print colored("retry $0",'green')."\n";
    exit;
}

# build go 1.6
my $tarball = download($go1_6_src);
$ENV{GOROOT_BOOTSTRAP} = "$go14_install_dir";
go_build($tarball, $go_install_dir);

print_go_env();

exit;

sub print_go_env {
    my $go_path = "$ENV{HOME}/go";
    my $env_go_path = $ENV{GOPATH} || '';

    if($go_path eq $env_go_path){
        print colored("GOPATH=$go_path   => OK",'green')."\n";
    }
    else {
        print colored("GOPATH=$go_path   => NG",'red')."\n";
        print colored("env GOPATH=$env_go_path",'red'),"\n" if length $env_go_path;
        print colored("set GOPATH=\$HOME/go", 'magenta'),"\n";
    }

    if( ($ENV{PATH} =~ /$go_install_dir\/bin/) && ($ENV{PATH} =~ /$go_path\/bin/)){
        print colored("PATH=$go_install_dir/bin   => OK",'green')."\n";
    }
    else {
        print colored("PATH=$go_install_dir/bin or \$GOPATH/bin => not found",'red')."\n";
        print colored("add PATH=\$HOME/local/$go_install_version/bin:\$GOPATH/bin:\$PATH", 'magenta'),"\n";
    }
}

sub download {
    my $url = shift;
    my $tarball = basename($url);
    return $tarball if -f $tarball;

    print "wget $url -O $tarball\n";
    system 'wget', $url, '-O', $tarball;
    return $tarball;
}

sub go_build {
    my($tarball, $build_dir) = @_;
    mkdir $build_dir if ! -d $build_dir;

    system 'tar', 'xf', $tarball, '-C', $build_dir, '--strip-components', '1';
    chdir $build_dir.'/src';
    open my $fh,'-|', './make.bash' or die $!;
    while(<$fh>){
        print;
    }
    close $fh;
}

sub go_version {
    my $url = shift;
    return basename($url, '.src.tar.gz','.tar.gz');
}

