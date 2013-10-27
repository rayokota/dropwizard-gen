# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','dropwizard_version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'dropwizard'
  s.version = Dropwizard::VERSION
  s.author = 'Robert Yokota'
  s.email = 'ryokota@yammer-inc.com'
  s.homepage = 'http://github.yammer.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A description of your project'
# Add your other files here if you make them
  s.files = %w(
bin/dropwizard
lib/dropwizard_version.rb
  )
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','dropwizard.rdoc']
  s.rdoc_options << '--title' << 'dropwizard' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'dropwizard'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_runtime_dependency('gli')
  s.add_runtime_dependency('artii')
  s.add_runtime_dependency('curl')
  s.add_runtime_dependency('linguistics')
  s.add_runtime_dependency('orderedhash')
  s.add_runtime_dependency('uri_template')
end
