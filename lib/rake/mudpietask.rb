require 'mudpie'
require 'mudpie/commands'
require 'rack'
require 'rack/mudpie'
require 'rake/clean'
require 'rake/tasklib'
require 'rake/sprocketstask'

class Rake::MudPieTask < Rake::TaskLib

  def initialize
    @db_path = MudPie::Pantry::DB_PATH
    @bakery = MudPie::Bakery.new
    yield self if block_given?
    define
  end

  def define
    CLEAN.include(@bakery.output_root.to_s)
    CLOBBER.include(@db_path.to_s)
    Rake::SprocketsTask.new do |t|
      t.environment = @bakery.sprockets_environment
      t.output      = File.join(@bakery.output_root, 'assets')
      t.assets      = @bakery.sprockets_assets
    end
    task :stock do
      MudPie::StockCommand.new(@bakery).execute
    end
    desc "Render pages to `#{@bakery.output_root}`"
    task :bake => [:stock, :assets] do
      MudPie::BakeCommand.new(@bakery).execute
    end
    desc "Compress files in `#{@bakery.output_root}`"
    task :compress do
      MudPie::CompressCommand.new(@bakery).execute
    end
    namespace :serve do
      desc "Start static HTTP server in `#{@bakery.output_root}`"
      task :cold do
        MudPie::ServeCommand.new(@bakery, :how => :cold).execute
      end
      desc "Start dynamic HTTP server for live previews."
      task :hot do
        MudPie::ServeCommand.new(@bakery, :how => :hot).execute
      end
    end
  end

end
