class NumberSet
  include Enumerable

  def initialize
    @set = []
  end

  def each(&block)
    @set.each(&block)
  end

  def <<(input_number)
    @set << input_number unless @set.include?(input_number)
  end

  def size
    @set.size
  end

  def empty?
    @set.empty?
  end

  def [](condition)
    @set.each_with_object([]) { |i , a| a << i if condition.filter.call(i) }
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
    Filter.new { |x| @filter.call(x) && other.filter.call(x) }
  end

  def |(other)
    Filter.new { |x| @filter.call(x) || other.filter.call(x) }
  end

end


class TypeFilter < Filter

  def initialize(type)
    @filter =
      case type
      when :integer then lambda { |number| number.is_a? Integer }
      when :real then lambda { |number| number.is_a?(Float) ||
                                          number.is_a?(Rational) }
      else lambda { |number| number.is_a? Complex }
      end
  end

end


class SignFilter < Filter

  def initialize(sign)
    @filter =
      case sign
      when :positive then lambda { |number| number > 0 }
      when :non_positive then lambda { |number| number <= 0 }
      when :negative then lambda { |number| number < 0 }
      else lambda { |number| number >= 0}
      end
  end

end