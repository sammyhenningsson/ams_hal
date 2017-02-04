module AmsHalAdapter
  class Adapter < ActiveModelSerializers::Adapter::Base
    def serialize(serializer, adapter_options, options)
      serialized = serializer.serializable_hash(adapter_options, options, self)

      if links = links_for(serializer)
        serialized[:_links] = links
      end
      serialized
    end

    def links_for(serializer)
      serializer._links.each_with_object({}) do |(rel, value), hash|
        href = Link.new(serializer, value).href
        hash[rel] = href unless href.blank?
      end
    end
  end
end
