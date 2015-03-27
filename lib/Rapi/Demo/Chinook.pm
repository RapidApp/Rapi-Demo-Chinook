package Rapi::Demo::Chinook;

use strict;
use warnings;

# ABSTRACT: PSGI version of the Chinook demo

use RapidApp 1.0203_01;

use Moose;
extends 'RapidApp::Builder';

our $VERSION = '0.01';

has '+base_appname', default => sub { 'Rapi::Demo::Chinook::App' };
has '+debug',        default => sub {1};

sub _build_plugins {[ 'RapidApp::RapidDbic' ]}

has '+inject_components', default => sub {[
  [ 'Rapi::Demo::Chinook::Model::DB' => 'Model::DB' ]
]};


1;