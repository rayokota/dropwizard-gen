# dropwizard-gen

dropwizard-gen is the [Dropwizard](http://dropwizard.codahale.com) Code Generator

## Installation

Install it from source by running:

    bundle install

Learn about the various options:

    dropwizard help

## Running dropwizard-gen

Creating a new Dropwizard service:

    dropwizard new APP

All subsequent commands must be run from the newly created APP directory.

Generating a resource:

    dropwizard generate resource NAME [GET | POST] URI_TEMPLATE [FORM_PARAM, …]
    
Generating scaffolding for a model:
    
    dropwizard generate model NAME ATTR:TYPE ...
      where TYPE is one of byte, short, int, long, float, 
                           double, boolean, string, date


Building a Dropwizard service:

    dropwizard build
    
Running a Dropwizard service:

    dropwizard server

In the case of generating a model, all instances of a model are created in the context of a specific network.  After generating a model, views to access the model (for network ID 1, for example) can be accessed at

    http://localhost:8080/networks/1/NAME_PLURAL
    
where NAME_PLURAL is the plural form of the NAME passed to the 'dropwizard generate model' command.
