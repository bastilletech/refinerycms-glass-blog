# Encoding: UTF-8

Gem::Specification.new do |s|
  s.platform          = Gem::Platform::RUBY
  s.name              = 'refinerycms-blog'
  s.version           = '1.0'
  s.description       = 'Ruby on Rails blog extension for Refinery CMS'
  s.date              = '2015-10-01'
  s.summary           = 'blog extension for Refinery CMS'
  s.authors           = 'Glass Canvas (glasscanvas.io)'
  s.require_paths     = %w(lib)
  s.files             = Dir["{app,config,db,lib}/**/*"] + ["readme.md"]

  # Runtime dependencies
  s.add_dependency             'refinerycms-core',     '~> 3.0.0'
  s.add_dependency             'acts_as_indexed',      '~> 0.8.0'

  # Development dependencies (usually used for testing)
  s.add_development_dependency 'refinerycms-testing', '~> 3.0.0'
end
