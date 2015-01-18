
node.default[:zapp_django_chef][:app_name] = 'zapp'

node.default[:zapp_django_chef][:user] = node[:zapp_django_chef][:app_name]
node.default[:zapp_django_chef][:group] = node[:zapp_django_chef][:app_name]
node.default[:zapp_django_chef][:directory] = "/srv/#{node[:zapp_django_chef][:app_name]}"
node.default[:zapp_django_chef][:requirements_file] = 'requirements.txt'
node.default[:zapp_django_chef][:repository] = ''
node.default[:zapp_django_chef][:url] = ''

# nginx
node.default[:zapp_django_chef][:nginx_port] = 80
node.default[:zapp_django_chef][:nginx_static_files] = {
  '/static' => 'app/static'
}

# database
node.default[:zapp_django_chef][:db] = {
  'database' => '',
  'adapter' => '',
  'username' => '',
  'password' => '',
  'host' => 'localhost',
  'port' => '3306'
}

# gunicorn
