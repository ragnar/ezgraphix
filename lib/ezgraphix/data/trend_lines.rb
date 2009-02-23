require File.dirname(__FILE__) + '/trend_lines/line'
require File.dirname(__FILE__) + '/trend_lines/zone'

module Ezgraphix
  module Data
    class TrendLines
      attr_accessor :options
      attr_reader :sets

      def initialize( o = {} )
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
        builder.tag!( :trendLines ) do |ds|
          sets.each do |s|
            s.to_xml( ds )
          end
        end
      end
    end

    #Returns a random color from the Graphic#COLORS collection.
    def rand_color
      Graphic::COLORS[rand(Graphic::COLORS.size - 1)]
    end
  end
end
