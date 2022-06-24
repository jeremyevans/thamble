spec = Gem::Specification.new do |s|
  s.name = 'thamble'
  s.version = '1.1.0'
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ["README.rdoc", "CHANGELOG", "MIT-LICENSE"]
  s.rdoc_options += ["--quiet", "--line-numbers", "--inline-source", '--title', 'Thamble: Create HTML Tables from Enumerables', '--main', 'README.rdoc']
  s.license = "MIT"
  s.summary = "Create HTML Tables from Enumerables"
  s.author = "Jeremy Evans"
  s.email = "code@jeremyevans.net"
  s.homepage = "http://github.com/jeremyevans/thamble"
  s.files = %w(MIT-LICENSE CHANGELOG README.rdoc Rakefile) + Dir["{spec,lib}/**/*.rb"]
  s.description = <<END
Thamble exposes a single method, table, for easily creating HTML
tables from enumerable objects.
END
  s.required_ruby_version = ">= 1.9.2"
  s.add_development_dependency 'minitest'
  s.add_development_dependency "minitest-global_expectations"
  s.add_development_dependency "activesupport"
end
