# vim: set filetype=ruby et sw=2 ts=2:

require 'gem_hadar'

GemHadar do
  name        'mize'
  author      'Florian Frank'
  email       'flori@ping.de'
  homepage    "http://flori.github.com/#{name}"
  summary     'Library that provides memoziation for methods and functions'
  description "#{summary} for Ruby."
  readme      'README.md'
  licenses << 'MIT'

  test_dir    'spec'
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', 'coverage', '.rvmrc',
    '.AppleDouble', 'tags', '.byebug_history', '.yard*', 'errors.lst'


  dependency 'protocol', '~> 2.0'
  development_dependency 'rake'
  development_dependency 'simplecov'
  development_dependency 'rspec'
  development_dependency 'yard'
  development_dependency 'all_images'

  required_ruby_version '>= 2'
end

namespace :yard do
  require 'pathname'

  yard_dir = Pathname.new('yard')

  desc 'Create yard documentation'
  task :create do
    sh 'yardoc'
  end

  desc 'View the yard documentation'
  task :view do
    index_file = yard_dir + 'index.html'
    File.exist?(index_file)
    sh "open #{index_file}"
  end

  desc 'Clean the yard documentation'
  task :clean do
    rm_rf yard_dir
  end
end

task :yard => %i[ yard:create yard:view ]

task :default => :spec
