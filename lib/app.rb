require 'sinatra'
require 'sinatra/contrib/all'
require 'sinatra/cache'
require 'sinatra/namespace'
require 'active_support/core_ext/hash/indifferent_access'
require 'nokogiri'
require 'logger'
require 'pp'

configure {
  set :server, :puma
}
 
#require_relative 'minify_resources'
Dir["#{File.dirname(__FILE__)}/lib/*.rb"].each { |f| load(f) }
Dir["#{$app_root}/lib/*.rb"].each { |f| load(f) }


#Bug Patch yet to be released
module Sinatra
	class ShowExceptions < Rack::ShowExceptions
		def call(env)
	      @app.call(env)
	    rescue Exception => e
	      errors, env["rack.errors"] = env["rack.errors"], @@eats_errors

	      if prefers_plain_text?(env)
	        content_type = "text/plain"
	        exception_string = dump_exception(e)
	      else
	        content_type = "text/html"
	        exception_string = pretty(env, e)
	      end

	      env["rack.errors"] = errors

	      # Post 893a2c50 in rack/rack, the #pretty method above, implemented in
	      # Rack::ShowExceptions, returns a String instead of an array.
	      body = Array(exception_string)

	      [
	        500,
	       {"Content-Type" => content_type,
	        "Content-Length" => Rack::Utils.bytesize(body.join).to_s},
	       body
	      ]
	    end
	end
end

class Pumatra < Sinatra::Base
	configure :development do
		require 'sinatra/reloader'
		register Sinatra::Reloader
		also_reload "#{File.dirname(__FILE__)}/lib/*.rb"
		also_reload "#{$app_root}/lib/*.rb"
		also_reload "#{$app_root}/config/initializers/*.rb"
		#also_reload "#{File.dirname(__FILE__)}/models/*.rb"
		also_reload "#{File.dirname(__FILE__)}/controllers/*.rb"
		also_reload "#{$app_root}/models/*.rb"
		also_reload "#{$app_root}/controllers/*.rb"
	end

	register Sinatra::Contrib
	register Sinatra::Validator
	register Sinatra::Namespace

	
	set :raise_errors, false
	set :dump_errors, true
	set :logging, true

	FileUtils::mkdir_p "#{$app_root}/log"
	::Logger.class_eval { alias :write :'<<' }
	
	access_log = ::File.new(File.join(::File.expand_path($app_root),'log',"#{settings.environment}_access.log"),"a+")
	access_log.sync=true
	access_logger = ::Logger.new(access_log)
	
	error_logger = ::File.new(::File.join(::File.expand_path($app_root),'log',"#{settings.environment}_error.log"),"a+")
	error_logger.sync = true

	use ::Rack::CommonLogger, access_logger

	before {
	    env["rack.errors"] =  error_logger
	}

	configure :production do
		#enable :sessions	

		#set :css_files, :Baslob
		#set :js_files,  :blob
		#MinifyResources.minify_all
	end

	configure :development do
		require 'rack/allocation_stats'
		use Rack::AllocationStats

		#require 'rack-static-if-present'

		use Rack::StaticIfPresent, :urls => ["/"], :root => "public"

		set :show_exceptions, true

		#set :css_files, MinifyResources::CSS_FILES
		#set :js_files,  MinifyResources::JS_FILES
		#ActiveRecord::Base.logger = logger
	end

	require 'rack/abstract_format'
	use Rack::AbstractFormat

	set :environment_vars, HashWithIndifferentAccess.new(YAML::load(File.open(File.join("#{$app_root}/config/environment_vars.yml"))))[settings.environment]

	def find_template(views, name, engine)
		if File.exist? ::File.join(views, "#{name}.#{@preferred_extension}")
	  		super(views, name, engine)
	  	elsif File.exist? ::File.join("#{File.dirname(__FILE__)}/views", "#{name}.#{@preferred_extension}")
	  		super("#{File.dirname(__FILE__)}/views", name, engine)
	  	else
	  		super(views, name, engine)
	  	end
	end
end

Dir["#{$app_root}/config/initializers/*.rb"].each { |f| load(f) }
#Dir["#{File.dirname(__FILE__)}/models/*.rb"].each { |f| load(f) }
Dir["#{File.dirname(__FILE__)}/controllers/*.rb"].each { |f| load(f) }
Dir["#{$app_root}/models/*.rb"].each { |f| load(f) }
Dir["#{$app_root}/controllers/*.rb"].each { |f| load(f) }