require 'test_helper'

class EmbeddedTest < ActiveSupport::TestCase

  class ChildResourceSerializer < ActiveModel::Serializer
    attributes :id, :foo
  end

  class EmbeddedSerializer < ActiveModel::Serializer
    include AmsHal::Embedded

    embed :parent
    embed :cousin do
      object.some_method(4)
    end
    embed :children, serializer: ChildResourceSerializer
  end

  class SubSerializer < EmbeddedSerializer
    embed :another_cousin do
      object.some_method(5)
    end
  end

  class ResourceWithEmbeds < ActiveModelSerializers::Model

    attr_accessor :id, :attr1

    def parent
      Resource.new(id: 1, foo: "foo1", bar: nil, baz: :more)
    end

    def children
      [
        Resource.new(id: 2, foo: "foo2"),
        Resource.new(id: 3, bar: "bar3"),
      ]
    end

    def some_method(id)
      Resource.new(id: id, foo: "foo#{id}")
    end

  end

  def setup
    @resource = ResourceWithEmbeds.new(id: 5, attr1: "Attr1")
  end

  test "that embedded resources are serialized" do
    serializable_resource = ActiveModelSerializers::SerializableResource.new(
      @resource,
      serializer: EmbeddedSerializer,
      adapter: AmsHal::Adapter
    )
    json = serializable_resource.as_json

    assert_equal 3, json[:_embedded].size
    assert_equal(
      {
        id: 1,
        foo: "foo1",
        bar: nil,
        _links: {
          self: { href: ResourceSerializer::SELF_LINK },
          edit: { href: ResourceSerializer::EDIT_LINK },
        },
      },
      json[:_embedded][:parent]
    )

    assert_equal(
      [
        {
          id: 2,
          foo: "foo2",
          bar: nil,
          _links: {
            self: { href: ResourceSerializer::SELF_LINK },
            edit: { href: ResourceSerializer::EDIT_LINK },
          },
        },
        {
          id: 3,
          foo: nil,
          bar: "bar3",
          _links: {
            self: { href: ResourceSerializer::SELF_LINK },
            edit: { href: ResourceSerializer::EDIT_LINK },
          },
        },
      ],
      json[:_embedded][:children]
    )

    assert_equal(
      {
        id: 4,
        foo: "foo4",
        bar: nil,
        _links: {
          self: { href: ResourceSerializer::SELF_LINK },
          edit: { href: ResourceSerializer::EDIT_LINK },
        },
      },
      json[:_embedded][:cousin]
    )
  end

  test "that serializers can inherit embeds" do 
    serializable_resource = ActiveModelSerializers::SerializableResource.new(
      @resource,
      serializer: SubSerializer,
      adapter: AmsHal::Adapter
    )
    json = serializable_resource.as_json
    assert_equal 4, json[:_embedded].size

    assert_equal(
      {
        id: 5,
        foo: "foo5",
        bar: nil,
        _links: {
          self: { href: ResourceSerializer::SELF_LINK },
          edit: { href: ResourceSerializer::EDIT_LINK },
        },
      },
      json[:_embedded][:another_cousin]
    )
  end

end

