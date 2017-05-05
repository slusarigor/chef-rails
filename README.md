# Chef (Ruby on Rails, Nginx, Passenger, Mysql, Redis, ImageMagick, Git), ready for Capistrano deploy.

Kitchen to setup an Ubuntu 16.04 for Ruby on Rails stack:

* Nginx
* Mysql
* Redis
* Ruby with RVM
* Phusion Passenger Standalone
* ImageMagick
* Git

## Requirements

* Ubuntu 16.04+

## Usage

To cook with this kitchen you must follow four easy steps.

### 0. Create server deploy user with SSH keys (Optional)

Create user

```bash
sudo adduser [new-user-name]
sudo adduser [new-user-name] sudo
```

Add SSH keys (MAC OS syntax. How generate SSH keys and add them from other systems you can find in Google :) )

```bash
cat ~/.ssh/id_rsa.pub | ssh [user]@[host] "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

### 1. Prepare your local working copy

```bash
git clone https://github.com/slusarigor/chef-rails.git chef
cd chef
bundle install
bundle exec librarian-chef install
```

### 2. Prepare the servers you want to configure

We need to copy chef-solo to any server we’re going to setup. For each server, execute

```bash
bundle exec knife solo prepare [user]@[host] -p [port]
```

where

* *user* is a user in the server with sudo and an authorized key.
* *host* is the ip or host of the server.
* *port* is the port in which ssh is listening on the server. Defaul port: 22.

This will create nodes/<your server>.json. Copy the contents from nodes/localhost.json.example into your host json file.
In the file, replace the samples between < > with the values for your server and applications.

```json
{
  // This is the list of the recipes that are going to be cooked.
  "run_list": [
    "recipe[apt]",
    "recipe[apt::default]",
    "recipe[sudo]",
    "recipe[packages::default]",
    "recipe[hostnames]",
    "recipe[ssh-hardening]",
    "recipe[chef_nginx::default]",
    "recipe[chef_nginx::passenger]",
    "recipe[main::nginx]",
    "recipe[ruby_build]",
    "recipe[ruby_rbenv::system]",
    "recipe[ruby_rbenv::user]",
    "recipe[redis::server]",
    "recipe[memcached]",
    "recipe[fail2ban]",
    "recipe[main::mysql]"
  ],
  "automatic": {
    "ipaddress": "<ip-address>"
  },

  // Add additional tools
  "packages-cookbook": [
    "git",
    "imagemagick",
    "htop",
    "mc"
  ],

  // Nginx default values configuration.
  // Also you can specify your default site configuration.
  "nginx": {
    "user"                : "<user-name>",
    "client_max_body_size": "2m",
    "worker_processes"    : "auto",
    "worker_connections"  : 768,
    "repository"          : "ppa",
    "daemon_disable"      : false,
    "default_site_enabled": false,
    "repo_source": "passenger",
    "package_name": "nginx-extras",
    "passenger": {
       "install_method": "package"
    }
  },

  // You must define who’s going to be the user(s) you’re going to use for deploy.
  "authorization": {
    "sudo": {
      "groups": [
        "sudo",
        "admin"
      ],
      "users": [
        "<user-name>"
      ],
      "passwordless": true
    }
  },

  "app": {
     "name": "<app-name>"
  },

  // Set hostname
  "set_fqdn": "<hostname>",

  // Install ruby
  "rbenv": {
    "user_installs": [
      {
        "user": "<user-name>",
        "rubies": [
          "<ruby-version>"
        ],
        "global"  : "<ruby-version>",
        "gems": {
          "<ruby-version>": [
            {
              "name": "bundle"
            }
          ]
        }
      }
    ]
  },

  // Fail2ban configuration to protect our server against SSH attack attempts
  "fail2ban": {
    "bantime": 600,
    "maxretry": 3,
    "backend": "auto"
  }
}

```

### 4. Mysql Config

By default mysql password set '111111', you can change this in '/site-cookbooks/main/recipes/mysql.rb'

### 5. Cooking

We’re now ready to cook. For each server you want to setup, execute

```bash
bundle exec knife solo cook [user]@[host] -p [port]
```

Remember to clean your kitchen after cook

```bash
bundle exec knife solo clean [user]@[host] -p [port]
```

### 6. Now you ready to deploy your project via capistrano.



## Tips

### 1. Some hosting by default have started apache service. You can simply stop it by:

Stop apache2
```bash
sudo systemctl stop apache2.service
```

Prevent apache2 to start at boot
```bash
sudo systemctl disable apache2.service
```

### 2. My default nginx config you can find and change in '/site-cookbooks/main/templates/site.erb'

### 3. You can manually start and stop it mysql

```bash
sudo service mysql-server start
sudo service mysql-server stop
```

### 4. You can manually start and stop nginx

```bash
sudo systemctl stop nginx
sudo systemctl start nginx
```

