require 'optparse'
require 'mudpie/configuration'
require 'mudpie/logger'

module MudPie
  module Command
    class BasicCommand
      attr_reader :path_args

      def initialize(argv)
        @path_args = option_parser.parse(argv)
      end

      def option_parser
        OptionParser.new do |opts|
          initialize_option_parser(opts)
          opts.on('-d', '--[no-]debug', 'display debugging output') do |flag|
            logger.debug = flag
          end
          opts.on('-q', '--[no-]quiet', 'generate no output') do |flag|
            logger.quiet = flag
          end
          opts.on_tail('-h', '--help', 'display this message') do
            puts opts
            exit
          end
        end
      end

      def initialize_option_parser(opts)
      end

      def config
        MudPie.config
      end

      def logger
        MudPie.logger
      end

      def run
        execute
      rescue => e
        logger.warn e.message
        logger.debug e.backtrace.join("\n")
      end

      def execute
        raise "`execute` not implemented by class #{self.class.name}"
      end
    end
  end
end