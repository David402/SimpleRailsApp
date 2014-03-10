require 'sinatra/base'
require 'sinatra/json'

# Ensure base_routes.rb gets loaded before all routes
require_relative "../routes/base_routes"

# Load up api files
paths = [
  'helpers', # helpers should come before routes because the later relies on the first
  'routes',
]
paths.each {|path|
  Dir[File.dirname(__FILE__) + "/../#{path}/*.rb"].each {|file| 
    require file 
  }  
}

