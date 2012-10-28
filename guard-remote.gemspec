# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'guard/remote'

Gem::Specification.new do |gem|
  gem.name          = "guard-remote"
  gem.version       = Guard::Remote::VERSION
  gem.authors       = ["Miguel Cabeça"]
  gem.email         = ["miguelcabeca@gmail.com"]
  gem.description   = %q{Guard plugin to sync your changes to a remote server via SFTP}
  gem.summary       = %q{Guard plugin to sync your changes to a remote server via SFTP}
  gem.homepage      = "https://github.com/cabeca/guard-remote"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.spec.add_dependency 'net-sftp'
end
