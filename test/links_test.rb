require 'test_helper'
require 'byebug'

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
end
