# == ezgraphix.rb
# This file contains the Ezgraphix module, and the Ezgraphix::Graphic class.
#
# == Summary
# A rails plugin to generate flash based graphics
# for rails applications using a free and customizable chart's set.
#
# == Installation
# Instructions are listed in the respository's README[http://github.com/jpemberthy/ezgraphix/tree/master/README.textile]
#
# == Online demo
# Online demo[http://ezgraphixdemo.herokugarden.com/] Hosted by HerokuGarden!
#
# == Contact
#
# Author::    Juan E Pemberthy
# Mail:: jpemberthy@gmail.com
# Copyright:: Copyright (c) 2008
# License::   Distributes under MIT License.

unless defined? Ezgraphix
  module Ezgraphix
    require File.dirname(__FILE__) + '/ezgraphix/data/set'
    require File.dirname(__FILE__) + '/ezgraphix/data/dataset'
    require File.dirname(__FILE__) + '/ezgraphix/data/lineset'
    require File.dirname(__FILE__) + '/ezgraphix/ezgraphix_helper'
    require 'builder'

    class InvalidChartType < StandardError; end #:nodoc:

    # This class contains the neccesary methods and attributes to render a Graphic,
    # most of time you will be playing with the render_options and _data_ attributes to
    # define the graphic's properties, also you can re-define those properties easily by accessing them
    # at any time.
    #
    # == Example
    # Define the Graphic in your controller.
    #   @g = Ezgraphix::Graphic.new  # render_options can also be passed from here,
    #                                # @g = Ezgraphix::Graphic.new(:div_name => 'my_graph', :w => 400)
    #
    #   @g.defaults
    #   => {:c_type=>'col3d', :div_name=>'ez_graphic', :w=>300, :h=>300}
    #
    #   @g.render_options #equals to defaults if not options were passed to the initializer.
    #   => {:c_type=>'col3d', :div_name=>'ez_graphic', :w=>300, :h=>300}
    #
    # It's always a good idea to change the div_name if your planning to render more
    # than one Graphic in the same page, this makes the graphic unique.
    #   @g.render_options(:div_name => 'my_graph')
    #   => {:c_type=>'col3d', :div_name=>'my_graph', :w=>300, :h=>300}
    #
    # In order to render, you have to feed the graphic with data you want to show, Ezgraphix uses
    # a Hash to represent that data where the keys represents names, for example:
    #   @g.data = {:ruby => 1, :perl => 2, :smalltalk => 3}
    #   => {:smalltalk => 3, :ruby => 1, :perl => 2}
    #
    # With this information, the graphic will be a column 3D, with a size of 300x300 pixels, indentified with the
    # "my_graph" name, with 3 columns containing the names: 'ruby', 'perl', and 'smalltalk' for the values 1,2,3 respectively.
    #
    # To render the graphic, from a view call the render_ezgraphix method defined in the Ezgraphix::Helper module.
    #  <%= render_ezgraphix @g %>
    #
    class Graphic
      include EzgraphixHelper

      #attr_accessor :swf_path
      attr_accessor :css_class
      attr_reader :chart_type

      # Hash containing all the render options. basic options are:
      # * <tt> :c_type</tt> -- Chart type to render.
      # * <tt> :div_name</tt> -- Name for the graphic, should be unique.
      # * <tt> :w </tt> -- Width in pixels.
      # * <tt> :h </tt> -- Height in pixels.
      # Full list of options are listed below render_options
      attr_accessor :render_options

      SWF_PUBLIC_PATH = "/FusionCharts"
      CHART_TYPES = ["Area2D", "Bar2D", "Bubble", "Column2D", "Column3D",
                     "Doughnut2D", "Doughnut3D", "Line", "MSArea", "MSBar2D",
                     "MSBar3D", "MSColumn2D", "MSColumn3D", "MSColumn3DLineDY",
                     "MSColumnLine3D", "MSCombi2D", "MSCombi3D", "MSCombiDY2D",
                     "MSLine", "MSStackedColumn2D", "MSStackedColumn2DLineDY",
                     "Pie2D", "Pie3D", "SSGrid", "Scatter", "ScrollArea2D",
                     "ScrollColumn2D", "ScrollCombi2D", "ScrollCombiDY2D",
                     "ScrollLine2D", "ScrollStackedColumn2D", "StackedArea2D",
                     "StackedBar2D", "StackedBar3D", "StackedColumn2D",
                     "StackedColumn3D", "StackedColumn3DLineDY", "Waterfall2D"
      ].freeze

      FCF_CHART_TYPES = ["FCF_Area2D", "FCF_Bar2D", "FCF_Candlestick",
                         "FCF_Column2D", "FCF_Column3D", "FCF_Doughnut2D",
                         "FCF_Funnel", "FCF_Gantt", "FCF_Line", "FCF_MSArea2D",
                         "FCF_MSBar2D", "FCF_MSColumn2D", "FCF_MSColumn2DLineDY",
                         "FCF_MSColumn3D", "FCF_MSColumn3DLineDY", "FCF_MSLine",
                         "FCF_Pie2D", "FCF_Pie3D", "FCF_StackedArea2D",
                         "FCF_StackedBar2D", "FCF_StackedColumn2D", "FCF_StackedColumn3D"
      ].freeze

      COLORS = ['AFD8f6', '8E468E', '588526', 'B3A000', 'B2FF66',
                'F984A1', 'A66EDD', 'B2FF66', '3300CC', '000033',
                '66FF33', '000000', 'FFFF00', '669966', 'FF3300',
                'F19CBB', '9966CC', '00FFFF', '4B5320', '007FFF',
                '0000FF', '66FF00', 'CD7F32', '964B00', 'CC5500']

      #Creates a new Graphic with the given _options_, if no _options_ are specified,
      #the new Graphic will be initalized with the Graphic#defaults options.
      def initialize( chart_type, options={}, debug = false, fcf = false)
        case fcf
        when false
          raise InvalidChartType, "Chart type must be one of these #{CHART_TYPES.join(", ")}" unless CHART_TYPES.include?(chart_type)
        when true
          raise InvalidChartType, "Chart type must be one of these #{FCF_CHART_TYPES.join(", ")}" unless FCF_CHART_TYPES.include?(chart_type)
        end
        @chart_type = chart_type
        @debug_mode = debug
        @render_options = defaults.merge!(options)
        @data = Hash.new
        @data_sets = Array.new
        @categories = Array.new
        @line_sets = Array.new
      end

      def debug?
        @debug_mode ? 1 : 0
      end

      #Returns defaults render options.
      def defaults
        {:w => 400, :h => 300, :div_name => 'ez_graphix'}
      end

      # Receives a Hash containing a set of render options that will be merged with the current configuration.
      #
      # ==== Options
      # Basics:
      # * <tt>:c_type</tt></tt> -- Chart type to render, default: "col3d" for Column 3D, supported chars:
      #     :c_type => "col3d"
      #     :c_type => "bar3d" #Bar3D
      #     :c_type => "bar2d" #Bar2D
      #     :c_type => "pie2d" #Pie2D
      #     :c_type => "pie3D" #Pie3D
      #     :c_type => "line"  #Line
      #     :c_type => "doug2d" #Doughnut2D
      # * <tt>:div_name</tt></tt> -- Name for the graphic, would be unique, default: "ez_graphic"
      # * <tt>:w</tt></tt> -- Width in pixels, default: 300
      # * <tt>:h</tt></tt> -- Height in pixels, default: 300
      # * <tt> :caption</tt> -- Graphic's caption, default: ""
      # * <tt> :subcaption</tt> -- Graphic's subcaption, default: ""
      # * <tt> :y_name</tt> -- Y axis name, default: ""
      # * <tt> :x_name</tt> -- X axis name, default: ""
      # Numbers:
      # * <tt> :prefix</tt> -- Prefix to values defined in the _data_ attribute, default: nil, some prefix could be
      #   :prefix => "$" or :prefix => "€"
      # * <tt> :precision</tt> -- Number of decimal places to which all numbers on the chart would be rounded to, default: 2
      # * <tt> :f_number</tt> -- Format number. if set to 0, numbers will not use separator, if set to 1 numbers will use separator
      # * <tt> :d_separator</tt> -- Decimal Separator, default: "."
      # * <tt> :t_separator</tt> -- Thousand Separator, default: ","
      # Design:
      # * <tt> :background</tt> -- Background Color
      # * <tt> :names</tt> -- Hide/Show(0/1) labels names, default: 1
      # * <tt> :values</tt> -- Hide/Show(0/1) Values, default: 1
      # * <tt> :limits</tt> -- Hide/Show(0/1) Limits.
      #
      def render_options(options={})
        @render_options.merge!(options)
      end

     #Returns the Graphic's type.
      def c_type
        @chart_type
      end

      #Returns the Graphic's width.
      def w
        self.render_options[:w]
      end

      #Returns the Graphic's height.
      def h
        self.render_options[:h]
      end

      #Returns the div's tag name would be unique if you want to render multiples graphics in the same page.
      def div_name
        self.render_options[:div_name]
      end

      def add_category (category)
        @categories << category
      end

      def add_categories( categories )
        @categories = categories
      end

      def add_dataset( data, options = {} )
        @data_sets << { :data => data, :options => options }
      end

      def add_lineset( ls )
        @line_sets << ls
      end

      #Builds the xml to feed the chart.
      def to_xml
        options = parse_options(self.render_options)
        xml = Builder::XmlMarkup.new

        xml.tag!( :graph, options ) do |graph|
          graph.tag!( :categories ) do |categories|
            @categories.each do |category|
              categories.tag!( :category, :name => category)
            end
          end unless @categories.empty?

          @data_sets.each do |content|
            content[:data].to_xml(graph)
          end unless @data_sets.empty?

          @line_sets.each do |line|
            line.to_xml(graph)
          end unless @line_sets.empty?
        end
        xml.target!
      end
    end
  end
end
