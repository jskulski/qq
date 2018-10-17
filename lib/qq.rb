require "qq/version"
require 'debug_inspector'

def jsk
  QQ::qq no="what"
end

module QQ

  def self.qq(*args)
    parent_binding = RubyVM::DebugInspector.open{|i| i.frame_binding(2) }
    local_variables = parent_binding.local_variables

    called_with = args.each_with_index.reduce([]) { |acc, value_index|
      arg_value, index = value_index
      arg_name = local_variables[index]
      acc.push({name: arg_name, value: arg_value})
      acc
    }

    generated = {
      called_at: Time.now,
      called_with: called_with,
      called_from: caller_locations(1,1)[0].label.to_sym
    }
    puts generated

    q_log = File.open('/tmp/q.log', mode="a")

    qq_io(generated, q_log) do |g|
      args_str = g[:called_with].reduce("") { |acc, arg|

        acc += if arg[:name]
                 "#{arg[:name]}=#{arg[:value]}"
               else
                 "#{arg[:value]}"
               end
        acc
      }
      "#{g[:called_from]}: #{args_str}"
    end

    q_log.close
  end

  def self.qq_generate(*args)
    parent_binding = RubyVM::DebugInspector.open{|i| i.frame_binding(3) }
    local_variables = parent_binding.local_variables

    called_with = args.each_with_index.reduce({}) { |acc, value_index|
      arg_value, index = value_index
      arg_name = local_variables[index]
      acc[arg_name] = arg_value
      acc
    }

    {
      called_at: Time.now,
      called_with: called_with,
      called_from: caller_locations(1,1)[0].label.to_sym
    }
  end

  def self.qq_io(generated, io)
    message = yield(generated)
    puts message
    puts File.read("/tmp/q.log")
    io.puts message
  end
end
