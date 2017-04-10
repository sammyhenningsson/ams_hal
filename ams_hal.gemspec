# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name        = 'ams_hal'
  gem.version     = '0.2.1'
  gem.date        = '2017-04-10'
  gem.summary     = "HAL adapter for active_model_serializers"
  gem.description = <<~EOS
                    Provides an adapter to use with ActiveModel::Serializer
                    so that resources can be serializer according to
                    HypertextApplicationLanguage.
                    EOS
  gem.authors     = ["Sammy Henningsson"]
  gem.email       = 'sammy.henningsson@gmail.com'
  gem.license     = "MIT"
  gem.homepage    = "https://github.com/sammyhenningsson/ams_hal"

  gem.files         = `git ls-files lib`.split
  gem.require_paths = ["lib"]

  gem.add_dependency "active_model_serializers", "~> 0.10.5"
  gem.add_dependency "activesupport", ">= 4.2"
  gem.add_development_dependency "rake"
end
