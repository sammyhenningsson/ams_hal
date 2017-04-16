module AmsHal
  class Adapter < ActiveModelSerializers::Adapter::Base
    def serializable_hash(options = {})
      options = serialization_options(options)
      options[:fields] ||= instance_options[:fields]
      hash = if serializer.respond_to?(:each)
                     serialize_collection(serializer, instance_options, options)
                   else
                     serialize_resource(serializer, instance_options, options)
                   end

      self.class.transform_key_casing!(hash, instance_options)
    end

    protected

    def serialize_resource(serializer, adapter_options, options)
      skip_embedded = options.delete(:skip_embedded) || false

      options[:include_directive] = {} # Don't include associations as attributes
      hash = serializer.serializable_hash(adapter_options, options, self)

      if links = serialize_links(serializer)
        hash[:_links] = links if links.any?
      end

      return hash if skip_embedded

      if embedded = serialize_embedded(serializer)
        hash[:_embedded] = embedded if embedded.any?
      end

      if associations = serialize_associations(serializer, adapter_options)
        hash[:_embedded] = associations if associations.any?
      end

      hash
    end

    def serialize_collection(serializer, adapter_options, options)
      options[:include_directive] = {} # Don't include associations as attributes
      hash = {}

      if links = serialize_links(serializer)
        hash[:_links] = links if links.any?
      end

      embedded = serializer.map do |_serializer|
        options[:skip_embedded] = true
        serialize_resource(_serializer, instance_options, options)
      end
      hash[:_embedded] = embedded if embedded.any?

      hash
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

    def serialize_associations(serializer, adapter_options)
      serializer.associations.each_with_object({}) do |association, embedded|
        embedded[association.name] =
          if association.serializer.nil? || association.serializer.object.nil?
            # active_model_serializers <= 0.10.4 
            object = serializer.object
            resource = object.public_send(association.name)
            serialized = [resource].flatten.map do |resrc|
              serialize_embedded_resource(resrc, serializer: association.serializer&.class)
            end
            serialized.size == 1 ? serialized.first : serialized
          elsif association.serializer.respond_to? :each
            association.serializer.map do |_serializer|
              serialize_resource(_serializer, instance_options, {skip_embedded: true})
            end
          else
            serialize_resource(association.serializer, instance_options, {skip_embedded: true})
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
