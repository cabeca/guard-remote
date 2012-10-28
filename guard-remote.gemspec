# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'guard/remote/version'

Gem::Specification.new do |gem|
  gem.name          = "guard-remote"
  gem.version       = Guard::Remote::VERSION
  gem.authors       = ["Miguel Cabeça"]
  gem.email         = ["miguelcabeca@gmail.com"]
  gem.summary       = %q{Guard plugin to sync your changes to a remote server via SFTP}
  gem.description   = %q{Guard plugin to sync your changes to a remote server via SFTP. Heavily inspired by guard-flopbox. This gem is experimental. It works for me but it may eat all your data, as it has file deletion logic that isn't much tested. You have been warned.}
  gem.homepage      = "https://github.com/cabeca/guard-remote"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'net-sftp'
end
