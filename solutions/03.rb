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
      data_type.to_s + ':' + @data.to_s
    end

    def self.parse(string_data)
      data_type, data = string_data.split(':', 2)
      case data_type
      when 'string' then File.new(data)
      when 'symbol' then File.new(data.to_sym)
      when 'number' then File.new(parse_number(data))
      when 'boolean' then File.new(data == 'true')
      else File.new
      end
    end

    def self.parse_number(string)
      if string.include?('.')
        string.to_f
      else
        string.to_i
      end
    end
  end

  class Parser
    def initialize(string_data)
      @string_data = string_data
    end

    def parse_entities
      num_entities, @string_data = @string_data.split(':', 2)

      num_entities.to_i.times do
        entity_name, entity_length, tail = @string_data.split(':', 3)
        yield entity_name, tail[0...entity_length.to_i]
        @string_data = tail[entity_length.to_i..-1]
      end
    end
  end

  class Directory
    attr_reader :files, :directories

    def initialize
      @files = {}
      @directories = {}
    end

    def add_file(name, file)
      @files[name] = file
    end

    def add_directory(name, directory = Directory.new)
      @directories[name] = directory
    end

    def [](name)
      @directories[name] || @files[name]
    end

    def serialize
      serialize_objects(@files) + serialize_objects(@directories)
    end

    def serialize_objects(objects)
      serialized_objects = objects.map do |name, object|
        serialized_object = object.serialize
        "#{name}:#{serialized_object.length}:#{serialized_object}"
      end
      "#{objects.count}:#{serialized_objects.join('')}"

    end

    def self.parse(string_data)
      new_dir = Directory.new
      parser = Parser.new(string_data)
      parser.parse_entities do |name, data|
        new_dir.add_file(name, File.parse(data))
      end
      parser.parse_entities do |name, data|
        new_dir.add_directory(name, Directory.parse(data))
      end

      new_dir
    end
  end
end