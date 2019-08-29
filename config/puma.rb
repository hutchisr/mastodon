min_threads = ENV.fetch('MIN_THREADS') { 0 }.to_i
max_threads = ENV.fetch('MAX_THREADS') { 8 }.to_i
threads min_threads, max_threads

if ENV['SOCKET']
  bind "unix://#{ENV['SOCKET']}"
else
  bind "tcp://#{ENV.fetch('BIND', '127.0.0.1')}:#{ENV.fetch('PORT', 3000)}"
end

environment ENV.fetch('RAILS_ENV') { 'development' }
workers     ENV.fetch('WEB_CONCURRENCY') { 2 }

preload_app!

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end

plugin :tmp_restart
