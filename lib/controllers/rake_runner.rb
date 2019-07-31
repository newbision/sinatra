require "pstore"
require 'fileutils'


class Pumatra < Sinatra::Base
	respond_to :html, :json, :xml
	namespace "/admin" do
		get "/rake_runner" do
			data=`rake -T`
			data=data.split("\n")
			data=data.map{|x| x.split('#').map{|y| y.rstrip.lstrip}}

			store = PStore.new("tmp/rake_runner.pstore")
			store.transaction(true) do  # begin transaction
				data.each do |task|
					if store[task[0].split(' ')[1]]
						task<<store[task[0].split(' ')[1]]

						task[2][:running]=false
						begin
						  Process.getpgid(task[2][:pid])
						  task[2][:running]=true
						rescue Errno::ESRCH

						end
					end
				end
			end

			respond_to do |f|
				f.json { json data, :encoder => :to_json, :content_type => :js }
				f.xml { data.to_xml }
				f.html { erb :"templates/status", :layout => :"layouts/main", :locals => { data:data} }
			end
		end

		get "/rake_runner/:task/output" do
			data={}
			store = PStore.new("tmp/rake_runner.pstore")
			store.transaction(true) do  # begin transaction
				data[params[:task]]=store[params[:task]]
			end
			
			if !data[params[:task]].nil?
				data[params[:task]][:running]=false
				pid=data[params[:task]][:pid]
				begin
				  Process.getpgid(pid)
				  data[params[:task]][:running]=true
				rescue Errno::ESRCH

				end
				data[params[:task]][:output]=File.read("tmp/rake_runner/#{pid}.output").split("\n") if File.exists?("tmp/rake_runner/#{pid}.output")
			end

			respond_to do |f|
				f.json { json data, :encoder => :to_json, :content_type => :js }
				f.xml { data.to_xml }
				f.html { erb :"templates/status", :layout => :"layouts/main", :locals => { data:data} }
			end
		end

		get "/rake_runner/:task/run" do
			data={}
			store = PStore.new("tmp/rake_runner.pstore")
			store.transaction(true) do  # begin transaction
				data[params[:task]]=store[params[:task]]
			end
			
			if !data[params[:task]].nil?
				data[params[:task]][:running]=false			
				old_pid=data[params[:task]][:pid]
				begin
				  Process.getpgid(data[params[:task]][:pid])
				  data[params[:task]][:running]=true
				rescue Errno::ESRCH

				end
			end

			if data[params[:task]].nil? || !data[params[:task]][:running]
				File.delete("tmp/rake_runner/#{old_pid}.output") if old_pid && File.exists?("tmp/rake_runner/#{old_pid}.output")
				pid = fork do 
					pid=Process.pid
					FileUtils::mkdir_p 'tmp/rake_runner'
					exec(("rake #{params[:task]} > tmp/rake_runner/#{pid}.output"))
				end
				Process.detach(pid)
				store.transaction do  # begin transaction
					store[params[:task]]={} if store[params[:task]].nil?
					store[params[:task]][:pid]=pid
					data[params[:task]]=store[params[:task]]
				end
				data[params[:task]][:started]=true
				data[params[:task]][:running]=false				
				begin
				  Process.getpgid(data[params[:task]][:pid])
				  data[params[:task]][:running]=true
				rescue Errno::ESRCH

				end
			end

			respond_to do |f|
				f.json { json data, :encoder => :to_json, :content_type => :js }
				f.xml { data.to_xml }
				f.html { erb :"templates/status", :layout => :"layouts/main", :locals => { data:data} }
			end
		end

		get "/rake_runner/:task/kill" do
			data={}
			store = PStore.new("tmp/rake_runner.pstore")
			store.transaction(true) do  # begin transaction
				data[params[:task]]=store[params[:task]]
			end
			
			if !data[params[:task]].nil?
				data[params[:task]][:running]=false
				pid=data[params[:task]][:pid]
				begin
				  Process.getpgid(data[params[:task]][:pid])
				  data[params[:task]][:running]=true
				rescue Errno::ESRCH

				end

				if data[params[:task]][:running]==true
					Process.kill(9, pid)
					sleep(0.5)
					data[params[:task]][:running]=false
					begin
					  Process.getpgid(data[params[:task]][:pid])
					  data[params[:task]][:running]=true
					rescue Errno::ESRCH

					end
				end
			end

			respond_to do |f|
				f.json { json data, :encoder => :to_json, :content_type => :js }
				f.xml { data.to_xml }
				f.html { erb :"templates/status", :layout => :"layouts/main", :locals => { data:data} }
			end
		end

		get "/rake_runner/:task" do
			data={}
			store = PStore.new("tmp/rake_runner.pstore")
			store.transaction(true) do  # begin transaction
				data[params[:task]]=store[params[:task]]
			end
			
			if !data[params[:task]].nil?
				data[params[:task]][:running]=false
				begin
				  Process.getpgid(data[params[:task]][:pid])
				  data[params[:task]][:running]=true
				rescue Errno::ESRCH

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