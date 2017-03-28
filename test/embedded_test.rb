require 'test_helper'

class EmbeddedTest < ActiveSupport::TestCase

  class EmbeddedSerializer < ActiveModel::Serializer
    include AmsHal::Embedded

    embed :parent
    embed :children
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
  end

  def setup
    resource = ResourceWithEmbeds.new(id: 5, attr1: "Attr1")
    serializable_resource = ActiveModelSerializers::SerializableResource.new(
      resource,
      serializer: EmbeddedSerializer,
      adapter: AmsHal::Adapter
    )
    @json = serializable_resource.as_json
  end

  test "that embedded resources are serialized" do
    puts @json
    assert_equal 2, @json[:_embedded].size
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
      @json[:_embedded][:parent]
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
      @json[:_embedded][:children]
    )
  end

end

