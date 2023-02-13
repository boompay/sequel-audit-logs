# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'sequel/audit_logs/version'

Gem::Specification.new do |spec|
  spec.name          = 'sequel-audit-logs'
  spec.version       = Sequel::AuditLogs::VERSION
  spec.authors       = %w[Kematzy tohchye jnylen gencer bsedin]
  spec.email         = %w[sergey@besedin.dev]

  spec.summary       = %q{A Sequel plugin that logs changes made to an audited model, including who created, updated and destroyed the record, and what was changed and when the change was made.}
  spec.description   = %q{A Sequel plugin that logs changes made to an audited model}
  spec.homepage      = 'https://github.com/bsedin/sequel-audit-logs'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']


  spec.add_runtime_dependency 'sequel', '>= 5.0.0'
  spec.add_runtime_dependency 'sequel_polymorphic'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  # spec.add_development_dependency 'minitest-hooks', '~> 1.2'
  # spec.add_development_dependency 'sqlite3', '~> 1.3'
  # spec.add_development_dependency 'simplecov', '~> 0.10'
  spec.add_development_dependency 'dotenv'
end
