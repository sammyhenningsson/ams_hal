require 'test_helper'

class AssociationsTest < ActiveSupport::TestCase

  class ChildResourceSerializer < ActiveModel::Serializer
    attributes :id, :foo
  end

  class AssociationsSerializer < ActiveModel::Serializer
    has_one :parent
    belongs_to :owner
    has_many :children, serializer: ChildResourceSerializer
  end

  class ResourceWithAssociations < ActiveModelSerializers::Model

    attr_accessor :id, :attr1

    def parent
      Resource.new(id: 1, foo: "parent", bar: nil, baz: :more)
    end

    def owner
      Resource.new(id: 2, foo: "owner", bar: nil, baz: :more)
    end

    def children
      [
        Resource.new(id: 3, foo: "child3"),
        Resource.new(id: 4, bar: "child4"),
      ]
    end
  end

  def setup
    resource = ResourceWithAssociations.new(id: 5, attr1: "Attr1")
    serializable_resource = ActiveModelSerializers::SerializableResource.new(
      resource,
      serializer: AssociationsSerializer,
      adapter: AmsHal::Adapter
    )
    @json = serializable_resource.as_json
  end

  test "that has_one association is embedded" do
    assert @json.dig(:_embedded, :parent)
    assert_equal(
      {
        id: 1,
        foo: "parent",
        bar: nil,
        _links: {
          self: { href: ResourceSerializer::SELF_LINK },
          edit: { href: ResourceSerializer::EDIT_LINK },
        },
      },
      @json[:_embedded][:parent]
    )
  end

  test "that belongs_to association is embedded" do
    assert @json.dig(:_embedded, :owner)
    assert_equal(
      {
        id: 2,
        foo: "owner",
        bar: nil,
        _links: {
          self: { href: ResourceSerializer::SELF_LINK },
          edit: { href: ResourceSerializer::EDIT_LINK },
        },
      },
      @json[:_embedded][:owner]
    )
  end

  test "that has_many association is embedded" do
    assert @json.dig(:_embedded, :children)
    assert_equal(
      [
        {
          id: 3,
          foo: "child3",
        },
        {
          id: 4,
          foo: nil,
        },
      ],
      @json[:_embedded][:children]
    )
  end

end


