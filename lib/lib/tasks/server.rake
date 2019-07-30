namespace :app do
  task :default => 'app:start'
  desc "Starts Application"
  task :start => :environment do
    puts "Starting Application"
    begin
      pid=File.read("#{Pumatra.root}/tmp/puma/pid").to_i
      if pid>0
        Process.getpgid(pid)
        puts 'Server is already running'
      else
        system('puma')
      end
    rescue Errno::ENOENT
      system('puma')
    rescue Errno::ESRCH
      system('puma')
    end
  end

  desc "Stop Application"
  task :stop => :environment do
    puts "Stoping Application"
    begin
      pid=File.read("#{Pumatra.root}/tmp/puma/pid").to_i
      Process.getpgid(pid)
      if File.file?("#{Pumatra.root}/tmp/puma/ctl_sock")
        `pumactl -S #{Pumatra.root}/tmp/puma/state stop`
      else
        Process.kill('INT', pid)
      end
    rescue Errno::ENOENT
      puts 'Server is not running'
    rescue Errno::ESRCH
      puts 'Server is not running2'
    end
  end
  
  desc 'Restart Application'
  task :restart => :environment do
    Rake::Task['app:stop'].invoke
    sleep 1
    Rake::Task['app:start'].invoke
  end
  
  desc "Restart Application Zero-Down"
  task :phased_restart => :environment do
    begin
      pid=File.read("#{Pumatra.root}/tmp/puma/pid").to_i
      Process.getpgid(pid)
      if File.file?("#{Pumatra.root}/tmp/puma/ctl_sock")
        puts 'No ctl_sock found'
      else
        `pumactl -S #{Pumatra.root}/tmp/puma/state phased-restart`
      end
    rescue Errno::ENOENT
      puts 'Server is not running'
    rescue Errno::ESRCH
      puts 'Server is not running'
    end
  end

  desc 'Listen to Application'
  task :listen => :environment do
    system("tail -f log/stderr log/stdout log/#{settings.environment}_access.log log/#{settings.environment}_error.log")
  end

  desc 'Application Console'
  task :console => :environment do
      require 'irb'
      ARGV.clear
      IRB.start
  end
end