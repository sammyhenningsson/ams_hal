require 'test_helper'

class HalAdapterTest < ActiveSupport::TestCase

  def setup
    resource = Resource.new(id: 5, foo: "test", bar: :more)
    @serializable_resource = ActiveModelSerializers::SerializableResource.new(resource, adapter: AmsHal::Adapter)
  end

  test "attributes" do
    puts @serializable_resource.to_json

    assert true
  end
end
