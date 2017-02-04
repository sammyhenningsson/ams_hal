module AmsHalAdapter
  class Link
    # FIXME: check that rails is used
    #include ::Rails.application.routes.url_helpers

    attr_reader :href

    def initialize(serializer, value)
      @object = serializer.object
      @scope = serializer.scope
      # Use the return value of the block unless it is nil.
      if value.respond_to?(:call)
        @self_before_instance_eval = eval "self", value.binding
        @href = instance_eval(&value)
      else
        @href = value
      end
    end

    protected

    def method_missing(method, *args, &block)
      @self_before_instance_eval.send method, *args, &block
    end

    attr_reader :object, :scope
  end
end
