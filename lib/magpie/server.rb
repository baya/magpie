# -*- coding: utf-8 -*-

module Magpie
  class Server < Rack::Server
    class Options
      def parse!(args)
        options = {}
        opt_parser = OptionParser.new("", 24, '  ') do |opts|
          opts.banner = "Usage: mag [rack options] [mag config]"

          opts.separator ""
          opts.separator "Rack options:"
          opts.on("-s", "--server SERVER", "serve using SERVER (webrick/mongrel)") { |s|
            options[:server] = s
          }

          opts.on("-o", "--host HOST", "listen on HOST (default: 0.0.0.0)") { |host|
            options[:Host] = host
          }

          opts.on("-p", "--port PORT", "use PORT (default: 9292)") { |port|
            options[:Port] = port
          }

          opts.on("-D", "--daemonize", "run daemonized in the background") { |d|
            options[:daemonize] = d ? true : false
          }

          opts.on("-P", "--pid FILE", "file to store PID (default: rack.pid)") { |f|
            options[:pid] = f
          }

          opts.on("-M", "--mode MODE", "开启magpie模式选项(bird, snake, 默认模式是bird)"){ |mode|
            options[:mode] = mode
          }

          opts.separator ""
          opts.separator "Common options:"

          opts.on_tail("-h", "--help", "Show this message") do
            puts opts
            exit
          end

          opts.on_tail("--version", "Show version") do
            puts "Magpie #{Magpie.version}"
            exit
          end
        end
        opt_parser.parse! args
        options[:yml] = args.last if args.last
        options
      end
    end

    def app
      #BIRD_APP
      SNAKE_APP
    end

    def default_options
      {
        :environment => "development",
        :pid         => "magpie.pid",
        :Port        => 9292,
        :Host        => "0.0.0.0",
        :AccessLog   => [],
        :yml         => "magpie.yml",
        :mode        => "bird"
      }
    end

    private
    def opt_parser
      Options.new
    end

    def parse_options(args)
      options = super
       if !::File.exist? options[:yml]
          abort "configuration file #{options[:yml]} not found"
        end
      Magpie.yml_db = ::YAML.load_file(options[:yml])
      options
    end

  end
end

