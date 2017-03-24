# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name        = 'ams_hal'
  gem.version     = '0.1.0'
  gem.date        = '2017-02-04'
  gem.summary     = "HAL adapter for active_model_serializers"
  gem.description = <<~EOS
                    Provides an adapter to use with ActiveModel::Serializer
                    so that resources can be serializer according to
                    HypertextApplicationLanguage.
                    EOS
  gem.authors     = ["Sammy Henningsson"]
  gem.email       = 'sammy.henningsson@gmail.com'
  gem.license       = "MIT"

  gem.files         = `git ls-files lib`.split
  gem.require_paths = ["lib"]

  gem.add_dependency "active_model_serializers", "~> 0.10.2"
  gem.add_development_dependency "activesupport", ">= 4.2"
  gem.add_development_dependency "rake"
end
