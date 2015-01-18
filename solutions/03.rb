module RBFS
  class File
    attr_accessor :data

    def initialize(data = nil)
      @data = data
    end

    def data_type
      case @data
        when String                then :string
        when Symbol                then :symbol
        when Fixnum, Float         then :number
        when TrueClass, FalseClass then :boolean
        when NilClass              then :nil
      end
    end

    def serialize
      data_type + ':' + @data.to_s
    end

    def self.parse(string_data)
      array = string_data.split(':', 2)
      case array[0]
      when 'string' then File.new(array[1])
      when 'symbol' then File.new(':' + array[1])
      when 'number' then File.new(to_number(array[1]))
      when 'boolean' then File.new(string == 'true')
      else File.new
      end
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
        dir.add_directory(data[0],
        RBFS::Directory.parse(data[2][0...data[1].to_i]))
        data = data[2][(data[1].to_i)..-1]
      end

      return data
    end
  end
end