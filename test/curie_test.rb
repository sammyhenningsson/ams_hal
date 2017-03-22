require 'test_helper'
require 'byebug'

class CurieTest < ActiveSupport::TestCase

  class CurieSerializer < ActiveModel::Serializer
    include AmsHal::Curies

    curie :doc do
      "http://example.com/docs/{rel}"
    end

    link :'doc:test' do
      "http://example.com/test"
    end
  end

  def setup
    resource = Resource.new(id: 5, foo: "test", bar: nil, baz: :more)
    serializable_resource = ActiveModelSerializers::SerializableResource.new(
      resource,
      serializer: CurieSerializer,
      adapter: AmsHal::Adapter
    )
    @json = serializable_resource.as_json
  end

  test "links" do
    assert_equal(
      { href: 'http://example.com/test' },
      @json.dig(:_links, :'doc:test')
    )
  end

  test "curie" do
    assert_equal(
      [
        {
          name: :doc,
          href: "http://example.com/docs/{rel}",
          templated: true
        }
      ],
      @json.dig(:_links, :curies)
    )
  end
end

