class NumberSet
  include Enumerable

  def initialize
    @array = []
  end

  def each
    if (block_given?)
      @array.each do |current|
        yield current
      end

      return @array
    else
      to_enum(:each)
    end
  end

  def <<(input_number)
    unless @array.include?(input_number)
      @array << input_number
    end
  end

  def size
    @array.size
  end

  def empty?
    @array.empty?
  end

  def [](condition)
    @array.each_with_object([]) { |i , a| a << i if condition.filter.call(i) }
  end

end


class Filter
  attr_reader :filter

  def initialize(&block)
    @filter = block
  end

  def to_proc
    ->(object, *args) { object.public_send self, *args}
  end

  def &(other)
    Filter.new { |x| @filter.call(x) and other.filter.call(x) }
  end

  def |(other)
    Filter.new { |x| @filter.call(x) or other.filter.call(x) }
  end

end


class TypeFilter < Filter

  def initialize(filter_key)
    @filter =
      case filter_key
      when :integer then lambda { |number| number.integer? }
      when :real then lambda { |number| number.real? and (not number.integer?) }
      else lambda { |number| number.eql?(number.to_c) }
      end
  end

end


class SignFilter < Filter

  def initialize(filter_key)
    @filter =
      case filter_key
      when :positive then lambda { |number| number > 0 }
      when :non_positive then lambda { |number| number <= 0 }
      when :negative then lambda { |number| number < 0 }
      else lambda { |number| number >= 0}
      end
  end

end