class Pumatra < Sinatra::Base
	respond_to :html, :json, :xml

	namespace "/admin" do
		helpers do
			def protected!
				return if authorized?
				headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
				data={errors:{message:"Not authorized"}}
				status 401
			  	respond_to do |f|
					f.json { json data, :encoder => :to_json, :content_type => :js }
					f.xml { data.to_xml }
					f.html { erb :"templates/status", :layout => :"layouts/main", :locals => { data:data} }
				end
			end

			def authorized?
				@auth ||=  Rack::Auth::Basic::Request.new(request.env)
				user= Pumatra.settings.environment_vars[:admin_user] ? Pumatra.settings.environment_vars[:admin_user] : 'admin'
				password= Pumatra.settings.environment_vars[:admin_password] ? Pumatra.settings.environment_vars[:admin_password] : '95gfv5jaWwERkxt6'
				@auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [user, password]
			end
		end

		before '/*' do
		  protected!
		end
	end

	before :method => :post do
		json_body_params ||= begin
			MultiJson.load(request.body.read.to_s, symbolize_keys: true)
		rescue MultiJson::LoadError
			{}
		end
		params.merge! json_body_params
	end 

	before :method => :put do
		json_body_params ||= begin
			MultiJson.load(request.body.read.to_s, symbolize_keys: true)
		rescue MultiJson::LoadError
			{}
		end
		params.merge! json_body_params
	end 

	configure :development do
		get "/error" do
			raise ZeroDivisionError
		end

		get '/__sinatra__/:image' do
			spec = Gem::Specification.find_by_name 'sinatra'
			filename = spec.gem_dir + "/lib/sinatra/images/#{params[:image].to_i}.png"
			content_type :png
			send_file filename
		end
	end

	add_validated_handler :GET, "/status", {
		description:"status check of server"
	}
	get "/status" do
 		#database.connection.execute("show tables")
 		data={
 			status:[
 				Enviornment: settings.environment,
 				DatabaseConnection: database.connected?
 			],
 			request:[
 				headers:env.select {|k,v| k.start_with? 'HTTP_'}
					    .collect {|pair| [pair[0].sub(/^HTTP_/, ''), pair[1]]}
					    .collect {|pair| pair.join(": ") << "<br>"}
					    .sort
 				#coookie:rack.request.cookie_hash
 			]

 		}
		
		respond_to do |f|
			f.json { json data, :encoder => :to_json, :content_type => :js }
			f.xml { data.to_xml }
			f.html { erb :"templates/status", :layout => :"layouts/main", :locals => { data:data} }
		end
	end

	configure :production do
		not_found do
		  	data={errors:{message:"Not Found"}}
		  	respond_to do |f|
				f.json { json data, :encoder => :to_json, :content_type => :js }
				f.xml { data.to_xml }
				f.html { erb :"templates/status", :layout => :"layouts/main", :locals => { data:data} }
			end
		end

		error 500 do
		  	data={errors:{error: @env['sinatra.error'].message, message:'Server Error'}}
		  	respond_to do |f|
				f.json { json data, :encoder => :to_json, :content_type => :js }
				f.xml { data.to_xml }
				f.html { erb :"templates/status", :layout => :"layouts/main", :locals => { data:data} }
			end
		end
	end
end
