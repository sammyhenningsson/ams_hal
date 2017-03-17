require 'active_model_serializers'

class ResourceSerializer < ActiveModel::Serializer
  SELF_LINK = "https://example.com/res/5"
  EDIT_LINK = "https://example.com/res/5/edit"

  attributes :id, :foo, :bar
  link :self, SELF_LINK
  link :edit, EDIT_LINK
end

