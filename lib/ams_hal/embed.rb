require 'active_model_serializers/serialization_context'

module AmsHal
  class Embed
    include ActiveModelSerializers::SerializationContext::UrlHelpers

    attr_reader :serializer, :name, :options

    def initialize(serializer, name, options = {}, &block)
      @serializer = serializer
      @name = name
      @options = options
      @block = block
    end

    def resource_for(serializer)
      @object = serializer.object
      @scope = serializer.scope

      @self_before_instance_eval = nil
      # Use the return value of the block unless it is nil.
      if @block
        @self_before_instance_eval = eval "self", @block.binding
        @resource = instance_eval(&@block)
      else
        @resource = @object.public_send(name)
      end
    end

    protected

    def method_missing(method, *args, &block)
      return super unless @self_before_instance_eval
      @self_before_instance_eval.send method, *args, &block
    end

    attr_reader :object, :scope
  end
end
