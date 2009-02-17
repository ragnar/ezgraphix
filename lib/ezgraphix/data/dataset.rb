module Ezgraphix
  module Data
    class Dataset
      attr_accessor :name
      attr_accessor :options
      attr_reader :sets
      
      def initialize( o )
        @incl_root = o.delete(:include_root)
        @opts = o
        @sets = Array.new
      end

      def add_set( set )
        self.sets << set
      end
      
      def << (set)
        add_set(set)
      end
      
      def to_xml( builder )
        if @incl_root && @incl_root == true
          o = sets.first.is_a?(Ezgraphix::Data::Dataset) ? {} : {:color => rand_color}.merge(@opts)
          builder.tag!( :dataset, o ) do |ds|
            sets.each do |s|
              s.to_xml(ds )
            end
          end
        else
          self.sets.each do |s|
            s.to_xml(builder)
          end
        end
      end

      #Returns a random color from the Graphic#COLORS collection.
      def rand_color
        Graphic::COLORS[rand(Graphic::COLORS.size - 1)]
      end
    end
  end
end
