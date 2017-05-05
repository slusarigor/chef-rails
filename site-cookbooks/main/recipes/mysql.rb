mysql_service 'server' do
  port '3306'
  version '5.7'
  initial_root_password '111111'
  action [:create, :start]
end

