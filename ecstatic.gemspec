# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ecstatic}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John MacFarlane"]
  s.date = %q{2009-07-21}
  s.default_executable = %q{ecstatic}
  s.description = %q{Ecstatic is a framework for maintaining a static website from templates and data in YAML files.}
  s.email = %q{jgm@berkeley.edu}
  s.executables = ["ecstatic"]
  s.extra_rdoc_files = [
    "ChangeLog",
     "README"
  ]
  s.files = [
    "ChangeLog",
     "README",
     "Rakefile",
     "VERSION",
     "YUI-LICENSE",
     "bin/ecstatic",
     "ecstatic.gemspec",
     "lib/ecstatic.rb",
     "samplesite/README",
     "samplesite/Rakefile",
     "samplesite/events.rbtxt",
     "samplesite/events.yaml",
     "samplesite/files/css/base-min.css",
     "samplesite/files/css/print.css",
     "samplesite/files/css/reset-fonts-grids.css",
     "samplesite/files/css/screen.css",
     "samplesite/index.txt",
     "samplesite/models/models.rb",
     "samplesite/siteindex.yaml",
     "samplesite/sitenav.yaml",
     "samplesite/standard.rbhtml"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jgm/cloudlib}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Framework for maintaining a static website from templates and data in YAML files.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 1.1"])
      s.add_runtime_dependency(%q<rake>, [">= 0.8.0"])
      s.add_runtime_dependency(%q<rpeg-markdown>, [">= 0.2"])
      s.add_runtime_dependency(%q<tenjin>, [">= 0.6.1"])
    else
      s.add_dependency(%q<activesupport>, [">= 1.1"])
      s.add_dependency(%q<rake>, [">= 0.8.0"])
      s.add_dependency(%q<rpeg-markdown>, [">= 0.2"])
      s.add_dependency(%q<tenjin>, [">= 0.6.1"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 1.1"])
    s.add_dependency(%q<rake>, [">= 0.8.0"])
    s.add_dependency(%q<rpeg-markdown>, [">= 0.2"])
    s.add_dependency(%q<tenjin>, [">= 0.6.1"])
  end
end
