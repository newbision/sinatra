require 'dalli'
require 'connection_pool'
require 'digest'

if Pumatra.settings.environment_vars[:memcached_server]
	class Pumatra < Sinatra::Base
		options = {:compress => true}
		options[:namespace] = Pumatra.settings.environment_vars[:memcached_namespace] if Pumatra.settings.environment_vars[:memcached_namespace]
		set :memcached, ConnectionPool.new(size: 5, timeout: 5) { Dalli::Client.new(Pumatra.settings.environment_vars[:memcached_server], options) }
	end

	class Pumatra < Sinatra::Base
		respond_to :html, :json, :xml
		namespace "/admin" do
			get "/memcached/stats" do
		 		data={}

		 		Pumatra.settings.memcached.with do |conn|
						data[:stats]=conn.stats
						data[:items]=conn.stats(:items)
						data[:slabs]=conn.stats(:slabs)
						data[:settings]=conn.stats(:settings)
				end if Pumatra.settings.memcached
				
				respond_to do |f|
					f.json { json data, :encoder => :to_json, :content_type => :js }
					f.xml { data.to_xml }
					f.html { erb :"templates/status", :layout => :"layouts/main", :locals => { data:data} }
				end
			end
		end
	end
end