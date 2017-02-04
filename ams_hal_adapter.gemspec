# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name        = 'ams_hal_adapter'
  gem.version     = '0.0.1'
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

  gem.add_dependency "active_model_serializers", ">= 10.2.0"
  gem.add_development_dependency "activesupport", ">= 3.0.0"
  gem.add_development_dependency "rake"
end