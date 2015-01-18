
include_recipe 'zapp_django_chef'

# configurations
app_name = node[:zapp_django_chef][:app_name]
django_dir = "#{node[:zapp_django_chef][:directory]}/current"
sock_file = "#{sock_dir}/#{app_name}.sock"
shared_dir = "#{node[:zapp_django_chef][:directory]}/shared/env/"
wsgi_module = "#{app_name}.wsgi:application"
settings_module = "#{app_name}.settings"
log_level = node[:zapp_django_chef][:log_level] || 'debug'
num_workers = 3

# install dependencies
package 'libffi-dev'

# assign secret_key value
secret_key = data_bag_item('keys','secret_key')['key']

# second secret_key escaped for supervisord pickiness!
secret_key_supervisord = "#{secret_key.gsub(/%/,'%%')}";

# add zapp_django user
user node[:zapp_django_chef][:user] do
  system true
  shell '/bin/bash'
  home node[:zapp_django_chef][:directory]
end

# create shared directory
directory "#{node[:zapp_django_chef][:directory]}/shared" do
  user node[:zapp_django_chef][:user]
  group node[:zapp_django_chef][:group]
  mode '0775'
  recursive true
end

# set environment variable
ENV['SECRET_KEY'] = secret_key

# setup gunicorn socket
sock_dir = "#{node[:zapp_django_chef][:directory]}/run"

# sock directory creation
directory sock_dir do
  action :create
  user node[:zapp_django_chef][:user]
  group node[:zapp_django_chef][:group]
  mode 0755
  recursive true
end

# install django
application app_name do
  path node[:zapp_django_chef][:directory]
  owner node[:zapp_django_chef][:user]
  group node[:zapp_django_chef][:group]
  repository node[:zapp_django_chef][:django_repository]
  revision 'master'
  migrate true
  rollback_on_error false

  django do
    requirements node[:zapp_django_chef][:requirements_file]
    debug true
    packages ['gunicorn']
    settings_template 'settings.py.erb'
    
    database do
      node[:zapp_django_chef][:db].each do |method, value|
        send(method, value)
      end
    end

    database_master_role node[:zapp_django_chef][:
  end

  gunicorn do
    host node[:zapp_django_chef][:url]
    app_module wsgi_module
    socket_path sock_file
    autostart true
    virtualenv shared_dir
    environment ({"SECRET_KEY"=>secret_key_supervisord})
  end

  nginx_load_balancer do
    server_name app_name
    port node[:zapp_django_chef][:nginx_port]
    application_socket ["#{sock_file} fail_timeout=0"]
    static_files (node[:zapp_django_chef][:nginx_static_files])
  end
end
