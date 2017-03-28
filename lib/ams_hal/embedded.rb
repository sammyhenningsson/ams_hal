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

      def embed(association)
        self._embedded << association
      end
    end

    def embedded
      self.class._embedded.dup
    end

  end
end

