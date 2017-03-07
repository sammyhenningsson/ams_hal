require 'active_model_serializers'
require 'ams_hal'
require 'active_support/test_case'
require 'minitest/autorun'

class Resource < ActiveModelSerializers::Model
  attr_accessor :id, :foo, :bar
end

class ResourceSerializer < ActiveModel::Serializer
  attributes :id, :foo, :bar
  link :self, "https://example.com/res/5"
end
