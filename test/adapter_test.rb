require 'test_helper'
require 'byebug'

class AdapterTest < ActiveSupport::TestCase

  def setup
    resource = Resource.new(id: 5, foo: "test", bar: nil, baz: :more)
    serializable_resource = ActiveModelSerializers::SerializableResource.new(
      resource,
      adapter: AmsHal::Adapter
    )
    @json = serializable_resource.as_json
  end

  test "attributes" do
    assert_equal [:id, :foo, :bar].sort, (@json.keys - [:_links]).sort
  end

end
