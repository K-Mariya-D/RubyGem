require File.expand_path('lib/normal_form_of_lambda_expressions/version', __dir__)

Gem::Specification.new do |spec|
  spec.name = 'normal_form_of_lambda_expressions'
  spec.version = LokaliseRails::VERSION
  spec.authors = ['Korchagina Mariya']
  spec.email = ['kmd2oo619@gmail.com']
  spec.summary = 'Converting lambda expressions to normal form'
  spec.discription = 'Сonverting Church`s lambda calculus to normal form using reduction. The redex selection strategy can be selected from several options.'
  spec.homepage = 'https://github.com/K-Mariya-D/RubyGem'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.3.8'

  spec.files = Dir['README.md', 'LICENSE',
                  'CHNGELOG.md', 'lib/**/*.rb',
                  'lib/**/*.rake', 'normal_form_of_lambda_expressions.gemspec',
                  '.github/*.md', 'Gemfile', 'Rakefile']
  
spec.extra_rdoc_files = ['README.md']

spec.add_development_dependency 'rubocop', '~> 0.60'
spec.add_development_dependency 'rubocop-performance', '~> 1.5'
spec.add_development_dependency 'rubocop-rspec', '~> 1.37'
end