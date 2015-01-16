module UI
  class TextScreen
    @text = ""

    def self.draw(&block)
      self.instance_eval(&block)
      return @text
    end

    def self.label(text: '', border: '', style: lambda{ |x| x })
      @text += border + '' + style.to_proc.call(text) + '' + border
    end

    def self.horizontal(style: lambda{ |x| x }, border: '', &block)
      group = HorizontalGroup.new group_style: style, group_border: border
      group.instance_eval(&block)
      @text += group.to_s
    end

    def self.vertical(style: lambda{ |x| x }, border: '', &block)
      group = VerticalGroup.new group_style: style, group_border: border
      group.instance_eval(&block)
      @text += group.to_s
    end
  end

  class Group
    def initialize(group_style: ,group_border:)
      @components = []
      @bordered = []
      @group_style = group_style
      @group_border = group_border
    end

    def label(text: '', border: '', style: lambda{ |x| x })
      text_group = @group_style.to_proc.call(text)
      @components << border + '' + style.to_proc.call(text_group) + '' + border
    end

    def horizontal(style: lambda{ |x| x }, border: '', &block)
      group = HorizontalGroup.new  group_style: style, group_border: border
      group.instance_eval(&block)
      @components << group.to_s
    end

    def vertical(style: lambda{ |x| x }, border: '', &block)
      group = VerticalGroup.new group_style: style, group_border: border
      group.instance_eval(&block)
      @components << group.to_s
    end
  end

  class VerticalGroup < Group
    def to_s
      self.border_components
      @bordered.join("\n") + "\n"
    end

    def border_components
      max_length = @components.zip(@components.map { |x| x = x.length }).max[1]
      @components.each do |current|
        gap = max_length - current.length
        @bordered << @group_border + current + ' ' * gap + @group_border
      end
    end
  end

  class HorizontalGroup < Group
    def to_s
      @group_border + @components.join('') + @group_border
    end
  end
end