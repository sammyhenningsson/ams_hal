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

    protected

    def serialize_resource(serializer, adapter_options, options)
      serialized = serializer.serializable_hash(adapter_options, options, self)

      if links = serialize_links(serializer)
        serialized[:_links] = links
      end

      if embedded = serialize_embedded(serializer)
        serialized[:_embedded] = embedded
      end

      serialized
    end

    def serialize_links(serializer)
      return unless serializer.respond_to? :_links
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

    def serialize_embedded(serializer)
      return unless serializer.respond_to? :embedded
      serializer.embedded.each_with_object({}) do |association, embedded|
        object = serializer.object
        if object&.respond_to? association
          resource = serializer.object.public_send(association)
        else
          puts "WARN: Failed to get association '#{association}' from resource (#{object})"
        end

        next unless resource

        resources = resource.respond_to?(:each) ? resource : [resource]
        serialized_resources = resources.map do |resrc|
          serialize_embedded_resource(resrc)
        end
        embedded[association] = resources.size == 1 ? serialized_resources.first : serialized_resources
      end
    end

    private

    def serialize_embedded_resource(resource)
      serializable_resource = ActiveModelSerializers::SerializableResource.new(
        resource,
        adapter: AmsHal::Adapter
      )
      serializable_resource.as_json
    end

  end
end
