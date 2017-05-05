template "#{node.nginx.dir}/sites-available/#{node.app.name}" do
  source "site.erb"
  mode 0644
  owner node.nginx.user
  group node.nginx.user
end

nginx_site "#{node.app.name}"