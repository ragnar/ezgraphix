module Ezgraphix
  module Data
    class TrendLines
      class Zone < Line
        attr_accessor :end_value

        def initialize( value, end_value, options = {} )
          super( value, options.merge({:isTrendZone => 1}))
          self.end_value = end_value
        end
        def to_xml( builder )
          builder.tag!( :line, options.merge({:startValue => self.value, :endValue => self.end_value}) )
        end
      end
    end
  end
end
