package Rapi::Demo::Chinook;

use strict;
use warnings;

# ABSTRACT: PSGI version of the Chinook demo

use RapidApp 1.0204;

use Moose;
extends 'RapidApp::Builder';

use Types::Standard qw(:all);

use RapidApp::Util ':all';
use File::ShareDir qw(dist_dir);
use FindBin;
use Path::Class qw(file dir);
use Module::Runtime;

our $VERSION = '0.01';

has '+base_appname', default => sub { 'Rapi::Demo::Chinook::App' };
has '+debug',        default => sub {1};

sub _build_plugins {[ 'RapidApp::RapidDbic' ]}

has 'share_dir', is => 'ro', isa => Str, lazy => 1, default => sub {
  my $self = shift;
  $ENV{RAPI_DEMO_CHINOOK_SHARE_DIR} || (
    try{dist_dir('Rapi-Demo-Chinook')} || (
      -d "$FindBin::Bin/share" ? "$FindBin::Bin/share" : "$FindBin::Bin/../share" 
    )
  )
};

has 'chinook_db', is => 'ro', isa => Str, lazy => 1, default => sub {
  my $self = shift;
  file( $self->share_dir, 'chinook.db' )->stringify
};


has '+inject_components', default => sub {
  my $self = shift;
  my $model = 'Rapi::Demo::Chinook::Model::DB';
  
  Module::Runtime::require_module($model);
  
  # Make sure the path is valid/exists:
  file( $self->chinook_db )->resolve;
  
  $model->config->{connect_info}{dsn} = join(':','dbi','SQLite',$self->chinook_db);

  return [
    [ $model => 'Model::DB' ]
  ]
};



1;