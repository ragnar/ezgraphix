module Ezgraphix
  module Data
    class TrendLines
      class Line
        attr_accessor :value
        attr_accessor :options

        def initialize( value, options = {} )
          self.value = value
          self.options = options
        end

        def to_xml( builder )
          builder.tag!( :line, options.merge({:startValue => self.value}) )
        end
      end
    end
  end
end
