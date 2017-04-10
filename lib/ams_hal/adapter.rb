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
      options[:include_directive] = {} # Don't include associations as attributes
      serialized = serializer.serializable_hash(adapter_options, options, self)

      if links = serialize_links(serializer)
        serialized[:_links] = links if links.any?
      end

      if embedded = serialize_embedded(serializer)
        serialized[:_embedded] = embedded if embedded.any?
      end

      if associations = serialize_associations(serializer)
        serialized[:_embedded] = associations if associations.any?
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
      return unless serializer.respond_to? :curies
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
      serializer.embedded.each_with_object({}) do |embed, embedded|
        resource = embed.resource_for(serializer)

        next unless resource

        serialized_resources = [resource].flatten.map do |resrc|
          serialize_embedded_resource(resrc)
        end
        embedded[embed.name] = if serialized_resources.size == 1
                                  serialized_resources.first
                                else
                                  serialized_resources
                                end
      end
    end

    def serialize_associations(serializer)
      serializer.associations.each_with_object({}) do |association, embedded|
        object = serializer.object
        if object&.respond_to? association.name
          resource = object.public_send(association.name)
        else
          puts "WARN: Failed to get '#{association.name}' association from resource (#{object})"
        end

        next unless resource

        if association.serializer.is_a? ActiveModel::Serializer::CollectionSerializer
          # Not sure if this could happen and perhaps we should fail instead of create an array??
          resource = [resource] unless resource.respond_to? :each

          embedded[association.name] = resource.map do |resrc|
            # FIXME: How to improve this?
            serialize_embedded_resource(
              resrc,
              serializer: association.serializer.send(:options)[:serializer]
            )
          end
        else
          embedded[association.name] = serialize_embedded_resource(
            resource, 
            serializer: association.serializer&.class
          )
        end
      end
    end

    private

    def serialize_embedded_resource(resource, serializer: nil)
      serializable_resource = ActiveModelSerializers::SerializableResource.new(
        resource,
        serializer: serializer,
        adapter: AmsHal::Adapter
      )
      serializable_resource.as_json
    end

  end
end
