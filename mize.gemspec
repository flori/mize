# -*- encoding: utf-8 -*-
# stub: mize 0.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "mize"
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Florian Frank"]
  s.date = "2016-01-07"
  s.description = "Library that provides memoziation for methods and functions for Ruby."
  s.email = "flori@ping.de"
  s.extra_rdoc_files = ["README.md", "lib/mize.rb", "lib/mize/cache_methods.rb", "lib/mize/memoize_method.rb", "lib/mize/version.rb"]
  s.files = [".gitignore", ".utilsrc", "Gemfile", "README.md", "Rakefile", "VERSION", "config/broken_config.yml", "config/config.yml", "lib/mize.rb", "lib/mize/cache_methods.rb", "lib/mize/memoize_method.rb", "lib/mize/version.rb", "mize.gemspec", "spec/mize/memoize_method_spec.rb", "spec/mize/version_spec.rb", "spec/spec_helper.rb"]
  s.homepage = "http://flori.github.com/mize"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--title", "Mize - Library that provides memoziation for methods and functions", "--main", "README.md"]
  s.rubygems_version = "2.5.1"
  s.summary = "Library that provides memoziation for methods and functions"
  s.test_files = ["spec/mize/memoize_method_spec.rb", "spec/mize/version_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<gem_hadar>, ["~> 1.3.1"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<byebug>, [">= 0"])
      s.add_runtime_dependency(%q<protocol>, [">= 0"])
    else
      s.add_dependency(%q<gem_hadar>, ["~> 1.3.1"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<byebug>, [">= 0"])
      s.add_dependency(%q<protocol>, [">= 0"])
    end
  else
    s.add_dependency(%q<gem_hadar>, ["~> 1.3.1"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<byebug>, [">= 0"])
    s.add_dependency(%q<protocol>, [">= 0"])
  end
end
