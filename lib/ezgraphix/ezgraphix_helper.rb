module Ezgraphix
  module EzgraphixHelper

    #method used in ActionView::Base to render graphics.
    def render_ezgraphix(g)
      content_tag( :div, :id => g.div_name, :class => g.css_class || nil) do
        javascript_tag() do
          <<-END
          var ezChart = new FusionCharts('#{f_type(g)}', '#{g.div_name}', '#{g.w}', '#{g.h}','#{g.debug?}','0');
          ezChart.setDataXML('#{g.to_xml}');
          ezChart.render('#{g.div_name}');
          END
        end
      end
    end
  
    def f_type(graph)
      "#{Ezgraphix::Graphic::SWF_PUBLIC_PATH}/#{graph.chart_type}.swf"
    end
      
    def parse_options(options)
    original_names = Hash.new
    
    options.each{|k,v|
      case k 
      when :y_name
        original_names['yAxisName'] = v
      when :caption
        original_names['caption'] = v
      when :subcaption
        original_names['subCaptions'] = v
      when :prefix
        original_names['numberPrefix'] = v
      when :precision
        original_names['decimalPrecision'] = v
      when :div_line_precision
        original_names['divlinedecimalPrecision'] = v
      when :limits_precision
        original_names['limitsdecimalPrecision'] = v
      when :f_number
        original_names['formatNumber'] = v
      when :f_number_scale
        original_names['formatNumberScale'] = v
      when :rotate
        original_names['rotateNames']  = v  
      when :background
        original_names['bgColor'] = v
      when :line
        original_names['lineColor'] = v
      when :names
        original_names['showNames'] = v
      when :values
        original_names['showValues'] = v
      when :limits
        original_names['showLimits'] = v
      when :y_lines
        original_names['numdivlines'] = v
      when :p_y
        original_names['parentYAxis'] = v
      when :d_separator
        original_names['decimalSeparator'] = v
      when :t_separator
        original_name['thousandSeparator'] = v
      when :left_label_name
        original_names['PYAxisName'] = v
      when :right_label_name
        original_names['SYAxisName'] = v
      when :x_name
        original_names['xAxisName'] = v
      when :animation
        original_names['animation'] = v
      else
        original_names[k] = v
      end
      }
    original_names
  end    
  end
end
