module Ezgraphix
  module Data
    class Dataset
      class Vline
        attr_accessor :options

        def initialize( options = {} )
          self.options = options
        end

        def to_xml( builder )
          builder.tag!( :vLine, options )
        end
      end
    end
  end
end
