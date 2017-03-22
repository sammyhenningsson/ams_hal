require 'test_helper'

class CuriesTest < ActiveSupport::TestCase

  class CurieSerializer < ActiveModel::Serializer
    include AmsHal::Curies

    curie :doc do
      'http://example.com/docs/{rel}'
    end

    curie :foo, 'http://example.com/foo/{rel}'

    link 'doc:test' do
      'http://example.com/test'
    end
  end

  class SubSerializer < CurieSerializer
    curie :doc2, 'http://example.com/doc2/{rel}'

    curie :doc3 do
      'http://example.com/doc3/{rel}'
    end
  end

  def setup
    @resource = Resource.new(id: 5, foo: 'test', bar: nil, baz: :more)
    @serializer = CurieSerializer.new(@resource)
  end

  test "respond do curie class method" do
    assert @serializer.respond_to? :curies
  end

  test "that curies are saved in _curies" do
    assert_equal(
      [:doc, :foo],
      @serializer.curies.keys
    )
  end

  test "that serializers can inherit curies" do
    @serializer = SubSerializer.new(@resource)
    assert_equal(
      [:doc, :foo, :doc2, :doc3],
      @serializer.curies.keys
    )
  end

  test "that _curies are not poluted with serializer is subclassed" do
    @serializer = SubSerializer.new(@resource)
    assert_equal(
      [:doc, :foo],
      CurieSerializer._curies.keys
    )
  end
end
