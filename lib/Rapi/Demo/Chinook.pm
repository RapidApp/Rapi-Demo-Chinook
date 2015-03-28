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

has '_init_chinook_db', is => 'ro', isa => Str, lazy => 1, default => sub {
  my $self = shift;
  file( $self->share_dir, '_init_chinook.db' )->stringify
}, init_arg => undef;

has 'chinook_db', is => 'ro', isa => Str, lazy => 1, default => sub {
  my $self = shift;
  # Default to the cwd
  file( 'chinook.db' )->stringify
};


has '+inject_components', default => sub {
  my $self = shift;
  my $model = 'Rapi::Demo::Chinook::Model::DB';
  
  my $db = file( $self->chinook_db );
  
  $self->init_db unless (-f $db);
  
  # Make sure the path is valid/exists:
  $db->resolve;
  
  Module::Runtime::require_module($model);
  $model->config->{connect_info}{dsn} = "dbi:SQLite:$db";

  return [
    [ $model => 'Model::DB' ]
  ]
};


sub init_db {
  my ($self, $ovr) = @_;
  
  my ($src,$dst) = (file($self->_init_chinook_db),file($self->chinook_db));
  
  die "init_db(): ERROR: init db file '$src' not found!" unless (-f $src);

  if(-e $dst) {
    if($ovr) {
      $dst->remove;
    }
    else {
      die "init_db(): Destination file '$dst' already exists -- call with true arg to overwrite.";
    }
  }
  
  print STDERR "Initializing $dst\n" if ($self->debug);
  $src->copy_to( $dst );
}

1;