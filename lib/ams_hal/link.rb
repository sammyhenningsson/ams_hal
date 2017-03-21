require 'active_model_serializers/serialization_context'

module AmsHal
  class Link
    include ActiveModelSerializers::SerializationContext::UrlHelpers

    attr_reader :value

    def initialize(serializer, value)
      @object = serializer.object
      @scope = serializer.scope
      @self_before_instance_eval = nil
      # Use the return value of the block unless it is nil.
      if value.respond_to?(:call)
        @self_before_instance_eval = eval "self", value.binding
        @value = instance_eval(&value)
      else
        @value = value
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
