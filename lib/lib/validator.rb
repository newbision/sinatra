module Sinatra
	module Validator
		module Helpers
			def merge_collisions
				(proc {|key, oldval, newval| Array(oldval)<< newval})
			end

			def check_hash key, value, params
				errors={}
				value[:keys].each do |k, v|
					errors.merge!(check_param(k, v, params), &merge_collisions)
				end if value[:keys]

				types={}.tap{ |h| value[:accepted_values].each {|v| h[v[:type]]=v}} if value[:accepted_values]
				params.each do |k, v|
					if !types.include? v.class.to_s.downcase
						errors[key]="#{v.class} Not acceptable type" 
					else
						tempvar=check_param(k, types[v.class.to_s.downcase], params)
						errors[key]=tempvar if tempvar.size>0
					end
				end if value[:accepted_values]

				return errors
			end

			def check_array key, value, params
				errors={}
				if params.class==Array
					params.each do |param|
						errors[key]="#{param.class} Not acceptable type" if !value[:accepted_values].include? param.class.to_s.downcase
					end
				else
					return {key => "Must Be an Array"}
				end
				return errors
			end

			def check_string key, value, params
				if params.class != String
					return {key => "Must Be String"}
				end
				return {}
			end

			def check_float key, value, params
				if !params.match(/[0-9]/)#params.class != Float
					return {key => "Must Be Float"}
				end
				return {}
			end

			def check_param key, value, params
				errors={} 
				if params[key.to_sym]
					errors.merge!(send("check_#{value[:type]}", key, value, params[key.to_sym]), &merge_collisions) if respond_to? "check_#{value[:type]}"
					if value[:custom_validator]
						Array(value[:custom_validator]).each do |method|
							error=send(method, params[key.to_sym]) if respond_to? method
							errors.merge!({key => error}, &merge_collisions)  if error
						end
					end
				elsif value[:required]
				 	errors= {key => "Missing Value"}
				end
				return errors
			end

			def params_check path
				errors={}
				settings.route_details[@env['REQUEST_METHOD'].to_sym][path][:params].each do |key, value|
					tmpvar=check_param(key, value, params)
					errors[key]=tmpvar if tmpvar.size > 0
				end if settings.route_details[@env['REQUEST_METHOD'].to_sym] && settings.route_details[@env['REQUEST_METHOD'].to_sym][path] && settings.route_details[@env['REQUEST_METHOD'].to_sym][path][:params]
				return errors
			end
		end

		 def add_validated_handler(action, path, options={})
			route_details=settings.route_details
			route_details[action]={} if route_details[action].nil?
			route_details[action][path]=options

			before path do
				errors=params_check path
				pp errors
				if errors.size > 0
					data={:errors=>errors}
					respond_to do |f|
						f.json { json data, :encoder => :to_json, :content_type => :js }
						f.xml { data.to_xml }
						f.html { erb :"templates/status", :layout => :"layouts/main", :locals => { data:data} }
					end
				end
			end if route_details[action][path][:params]

			set :route_details, route_details
		end	
		
		def self.registered(app)
			app.helpers Validator::Helpers

			app.set :route_details, {}
			
			app.add_validated_handler :GET, "/index", {
				description:"Show List of API URLs"
			}
			app.get "/index" do 
				 data={}
				 settings.routes.slice("GET", "PUT", "POST", "DELETE").each do |action, routes|
				 		action=action.to_sym
				 		data[action]={}
				 		routes.each do |route|
					 		r_name=route[3].instance_variable_get(:@route_name).gsub(/^[A-Z]* /, '')
							if settings.route_details[action] && settings.route_details[action][r_name]
								data[action][r_name]=settings.route_details[action][r_name]
							else
								data[action][r_name]="No Details"
							end
						end
				 	end
				 respond_to do |f|
				 	f.json { json data, :encoder => :to_json, :content_type => :js }
				 	f.xml { data.to_xml }
				 	f.html { erb :"templates/status", :layout => :"layouts/main", :locals => { data:data} }
				 end	
			end
		end
	end
end