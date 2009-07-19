Gem::Specification.new do |s|
  s.name     = "ecstatic"
  s.version  = "0.1"
  s.date     = "2009-07-19"
  s.summary  = "Framework for maintaining a static website from templates and data in YAML files."
  s.email    = "jgm@berkeley.edu"
  s.homepage = "http://github.com/jgm/cloudlib"
  s.description = "Ecstatic is a framework for maintaining a static website from templates and data in YAML files."
  s.has_rdoc = true
  s.authors  = ["John MacFarlane"]
  s.bindir   = "bin"
  s.executables = ["ecstatic"]
  s.default_executable = "ecstatic"
  s.files    = File.open("Manifest.txt").readlines.map {|x| x.chomp}
  s.test_files = []
  s.rdoc_options = ["--main", "README", "--inline-source"]
  s.extra_rdoc_files = ["README"]
  s.add_dependency("activesupport", [">= 1.1"])
  s.add_dependency("rpeg-markdown", [">= 0.2"])
  s.add_dependency("tenjin", [">= 0.6.1"])
end

