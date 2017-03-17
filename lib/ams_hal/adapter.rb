module AmsHal
  class Adapter < ActiveModelSerializers::Adapter::Base
    def serializable_hash(options = nil)
      options = serialization_options(options)
      options[:fields] ||= instance_options[:fields]
      serialized = if serializer.respond_to?(:each)
                     serializer.each_with_object([]) do |_serializer, array|
                       array << serialize_resource(_serializer, instance_options, options)
                     end
                   else
                     serialize_resource(serializer, instance_options, options)
                   end

      self.class.transform_key_casing!(serialized, instance_options)
    end

    def serialize_resource(serializer, adapter_options, options)
      serialized = serializer.serializable_hash(adapter_options, options, self)

      if links = serialize_links(serializer)
        serialized[:_links] = links
      end
      serialized
    end

    def serialize_links(serializer)
      serializer._links.each_with_object({}) do |(rel, value), hash|
        href = Link.new(serializer, value).href
        hash[rel] = { href: href } unless href.blank?
      end
    end
  end
end
