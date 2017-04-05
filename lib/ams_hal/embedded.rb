module AmsHal
  module Embedded

    def self.included(base)
      base.extend ClassMethods
      base._embedded = []
    end

    module ClassMethods
      attr_accessor :_embedded

      def inherited(subclass)
        super
        subclass._embedded = _embedded.dup
      end

      def embed(name, options = {}, &block)
        self._embedded << Embed.new(self, name, options, &block)
      end
    end

    def embedded
      self.class._embedded.dup
    end

  end
end

