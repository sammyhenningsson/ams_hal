require 'test_helper'

class LinksTest < ActiveSupport::TestCase

  def setup
    resource = Resource.new(id: 5, foo: "test", bar: nil, baz: :more)
    serializable_resource = ActiveModelSerializers::SerializableResource.new(
      resource,
      adapter: AmsHal::Adapter
    )
    @json = serializable_resource.as_json
  end

  test "links" do
    assert_equal(
      {
        self: { href: ResourceSerializer::SELF_LINK },
        edit: { href: ResourceSerializer::EDIT_LINK }
      },
      @json[:_links]
    )
  end

  test "multiple links with same rel" do
    class MultiLinkSerializer < ActiveModel::Serializer
      link :children do
        [
          "children/1",
          "children/2"
        ]
      end

      link :single do
        "one/1"
      end
    end

    resource = Resource.new(id: 5, foo: "test", bar: nil, baz: :more)
    serializable_resource = ActiveModelSerializers::SerializableResource.new(
      resource,
      serializer: MultiLinkSerializer,
      adapter: AmsHal::Adapter
    )

    assert_equal(
      {
        single: { href: "one/1" },
        children: [
          { href: "children/1" },
          { href: "children/2" },
        ]
      },
      serializable_resource.as_json[:_links]
    )
  end

  test "that serializer class context can be accessed from block" do
    class ContextSerializer < ActiveModel::Serializer
      def self.some_class_method
        "link/from/class/method"
      end

      link :foo do
        some_class_method
      end

    end

    resource = Resource.new(id: 5, foo: "test", bar: nil, baz: :more)
    serializable_resource = ActiveModelSerializers::SerializableResource.new(
      resource,
      serializer: ContextSerializer,
      adapter: AmsHal::Adapter
    )

    assert_equal(
      {
        foo: { href: "link/from/class/method" },
      },
      serializable_resource.as_json[:_links]
    )
  end
end
