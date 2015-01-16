module RBFS
  class File
    def initialize(data = nil)
      @content = data
      self.define_type
    end

    def define_type
      @type =
        case
        when @content.is_a?(String) then :string
        when @content.is_a?(Symbol) then :symbol
        when @content.is_a?(Fixnum) || @content.is_a?(Float) then :number
        when @content.is_a?(TrueClass) || @content.is_a?(FalseClass) then :boolean
        else :nil
        end
    end

    def data_type
      return @type
    end

    def data=(new_data)
      @content = new_data
      self.define_type
    end

    def serialize
      @type.to_s + ':' + @content.to_s
    end

    def self.parse(string_data)
      array = string_data.split(':', 2)
      case array[0]
      when 'string' then File.new(array[1])
      when 'symbol' then File.new(':' + array[1])
      when 'number' then File.new(to_number(array[1]))
      when 'boolean' then File.new(to_boolean(array[1]))
      else File.new
      end
    end

    def self.to_boolean(string)
      string == 'true'
    end

    def self.to_number(string)
      if string.include?('.')
        string.to_f
      else
        string.to_i
      end
    end
  end

  class BaseDirectory
    attr_reader :files
    attr_reader :directories

    def initialize
      @files = {}
      @directories = {}
    end

    def add_file(name, file)
      @files[name] = file
    end

    def add_directory(name, directory = nil)
      if directory
        @directories[name] = directory
      else
        @directories[name] = Directory.new
      end
    end

    def [](name)
      if @directories.has_key?(name)
        @directories[name]
      elsif @files.has_key?(name)
        @files[name]
      else
        return nil
      end
    end

  end

  class Directory <BaseDirectory
    def serialize
      return serialize_structure(@files) + serialize_structure(@directories)
    end

    def serialize_structure(structure)
      result = structure.size.to_s + ':'
      structure.each do |name, type|
        result += "#{name}:" + type.serialize.length.to_s + ':' + type.serialize
      end
      return result
    end

    def self.parse(string_data)
      new_dir = Directory.new
      data = string_data
      data = parse_file(data, new_dir)
      parse_directory(data, new_dir)
      return new_dir
    end

    def self.parse_file(data, dir)
      type_count = data.split(':', 2).first.to_i
      data = data.split(':', 2).last
      type_count.times do
        data = data.split(':',3)
        dir.add_file(data[0], RBFS::File.parse(data[2][0...data[1].to_i]))
        data = data[2][(data[1].to_i)..-1]
      end

      return data
    end

    def self.parse_directory(data, dir)
      type_count = data.split(':', 2).first.to_i
      data = data.split(':', 2).last
      type_count.times do
        data = data.split(':',3)
        dir.add_directory(data[0], RBFS::Directory.parse(data[2][0...data[1].to_i]))
        data = data[2][(data[1].to_i)..-1]
      end

      return data
    end
  end
end