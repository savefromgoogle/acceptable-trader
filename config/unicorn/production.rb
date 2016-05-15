# set path to application
app_dir = "/home/rails/acceptable-trader"
shared_dir = "#{app_dir}/tmp"
working_directory app_dir


# Set unicorn options
worker_processes 2
preload_app true
timeout 30

# Set up socket location
listen "/home/rails/acceptable-trader/tmp/sockets/unicorn.trade.sock", :backlog => 64

# Logging
stderr_path "#{app_dir}/log/unicorn.stderr.log"
stdout_path "#{app_dir}/log/unicorn.stdout.log"

# Set master PID location
pid "#{shared_dir}/pids/unicorn.pid"