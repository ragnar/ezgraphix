module Ezgraphix
  module Data
    class Set
      attr_accessor :value
      attr_accessor :options

      def initialize( value, options = {} )
        self.value = value
        self.options = options
      end

      def to_xml( builder )
        builder.tag!( :set, options.merge({:value => self.value}) )
      end
    end
  end
end
