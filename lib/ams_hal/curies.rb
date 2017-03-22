module AmsHal
  module Curies

    def self.included(base)
      base.extend ClassMethods
      base._curies = {}
    end

    module ClassMethods
      attr_accessor :_curies

      def inherited(subclass)
        super
        subclass._curies = _curies.dup
      end

      def curie(name, value = nil, &block)
        _curies[name] = block || value
      end
    end

    def curies
      self.class._curies.dup
    end

  end
end

