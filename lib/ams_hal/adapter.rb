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
      links = serializer._links.each_with_object({}) do |(rel, value), hash|
        link = Link.new(serializer, value).value
        [link].flatten.each do |href|
          next unless href
          if hash.key? rel
            hash[rel] = [hash[rel]] unless hash[rel].is_a? Array
            hash[rel] << { href: href }
          else
            hash[rel] = { href: href }
          end
        end
      end
      curies = serialize_curies(serializer)
      links[:curies] = curies if curies

      links
    end

    def serialize_curies(serializer)
      return unless serializer.class.included_modules.include? AmsHal::Curies
      serializer.curies.each_with_object([]) do |(name, value), array|
        href = Link.new(serializer, value).value
        array << {
          name: name,
          href: href,
          templated: true
        }
      end
    end
  end
end
