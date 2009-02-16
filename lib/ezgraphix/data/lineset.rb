module Ezgraphix
  module Data
    class Lineset
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
        builder.tag!( :lineset, @opts ) do |ls|
          sets.each do |s|
            s.to_xml( ls )
          end
        end
      end
    end
  end
end
