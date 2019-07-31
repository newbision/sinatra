require 'fileutils'

class Pumatra < Sinatra::Base
	respond_to :html, :json, :xml
	namespace "/admin" do	
		get "/logs" do
			data=Dir["log/*"]
			respond_to do |f|
				f.json { json data, :encoder => :to_json, :content_type => :js }
				f.xml { data.to_xml }
				f.html { erb :"templates/status", :layout => :"layouts/main", :locals => { data:data} }
			end
		end

		get "/logs/:filename" do
			files=Dir["log/*"]

			file="log/#{params[:filename]}"
			data={}
			if files.include? file 
				data[file]=`tail -n 1000 #{file}`.split("\n")
			end
			
			respond_to do |f|
				f.json { json data, :encoder => :to_json, :content_type => :js }
				f.xml { data.to_xml }
				f.html { erb :"templates/status", :layout => :"layouts/main", :locals => { data:data} }
			end
		end

		get "/logs/:filename/:time" do
			files=Dir["log/*"]

			file="log/#{params[:filename]}"
			data={}
			if files.include? file 
				data[file]=`(tail -f #{file} & P=$! ; sleep #{params[:time]}; kill -9 $P)`.split("\n")
			end
			
			respond_to do |f|
				f.json { json data, :encoder => :to_json, :content_type => :js }
				f.xml { data.to_xml }
				f.html { erb :"templates/status", :layout => :"layouts/main", :locals => { data:data} }
			end
		end
	end
end