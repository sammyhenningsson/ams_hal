require 'test_helper'

class ExamplesTest < ActiveSupport::TestCase

  class Comment < ActiveModelSerializers::Model
    attr_accessor :text
  end

  class Post < ActiveModelSerializers::Model

    attr_accessor :title, :message

    def comments
      [
        Comment.new(text: "some important comments"),
        Comment.new(text: "more comments"),
      ]
    end
  end

  class PostSerializer < ActiveModel::Serializer
    attributes :title, :message
    link :author do
      "https://example.com/users/1"
    end
    has_many :comments
  end

  class PostHALSerializer < ActiveModel::Serializer
    include AmsHal::Embedded
    include AmsHal::Curies

    attributes :title, :message

    link :author do
      "https://example.com/users/1"
    end

    embed :comments do
      object.comments
    end

    curie :doc do
      "http://example.com/docs/{rel}"
    end
  end

  def setup
    @resource = Post.new(title: 'hello', message: 'lorem ipsum..')
  end

  test "combined serializer" do
    serializable_resource = ActiveModelSerializers::SerializableResource.new(
      @resource,
      adapter: AmsHal::Adapter
    )
    json = serializable_resource.as_json
    puts json.to_json
  end

  test "hal serializer" do
    serializable_resource = ActiveModelSerializers::SerializableResource.new(
      @resource,
      serializer: PostHALSerializer,
      adapter: AmsHal::Adapter
    )
    json = serializable_resource.as_json
    puts json.to_json
  end

end
