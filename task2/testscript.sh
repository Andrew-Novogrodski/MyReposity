#!/bin/bash
    echo Updating repositories...
    yum update -y

    echo Installing epel repositories...
    yum -y install epel-release > /dev/null
    if [ $? != 0 ]; then exit 1; fi
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 > /dev/null

    echo Installing ius repositories...
    curl -sS https://setup.ius.io/ | bash > /dev/null
    if [ $? != 0 ]; then exit 1; fi
    rpm --import /etc/pki/rpm-gpg/IUS-COMMUNITY-GPG-KEY > /dev/null

    echo Installing Nginx official repositories...
    cat > /etc/yum.repos.d/nginx.repo <<EOF
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/\$basearch/
gpgcheck=0
enabled=1
EOF

    echo Ingstalling packages...
    yum install -y nginx
    if [ $? != 0 ]; then exit 1; fi

    echo Create configurations files...
    mkdir /etc/nginx/default.d
    cd /etc/nginx/default.d
    cat > /etc/nginx/default.d/default.conf <<EOF
user  nginx;
worker_processes  4;
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;
events {
    worker_connections  1024;
}
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  off;
    sendfile        on;
    #tcp_nopush     on;
    keepalive_timeout  65;
    client_max_body_size 16m;
    client_body_buffer_size 1024k;
    server_names_hash_bucket_size 128;
    gzip  on;
    gzip_min_length 1k;
    fastcgi_intercept_errors on;
    ssl_session_cache   shared:SSL:10m;
    ssl_session_timeout 10m;
    server_tokens off;
    server {
        listen       80 default;
        server_name  _;
        location / {
            root   /usr/share/nginx/html;
            index  index.php index.html index.htm;
            location ~ ^/.+\.php {
                fastcgi_param  SCRIPT_FILENAME    \$document_root\$fastcgi_script_name;
                fastcgi_index  index.php;
                fastcgi_split_path_info ^(.+\.php)(/?.+)\$;
                fastcgi_param PATH_INFO \$fastcgi_path_info;
                fastcgi_param PATH_TRANSLATED \$document_root\$fastcgi_path_info;
                include        fastcgi_params;
                fastcgi_pass   127.0.0.1:9000;
            }
        }
    }
	include /etc/nginx/default.d/*.conf;
}
EOF

    echo Moving Configuration...
    rm -f /etc/nginx/nginx.conf
    cp  /etc/nginx/default.d/default.conf /etc/nginx/nginx.conf
    rm -f /etc/nginx/default.d/default.conf

    cat > /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
<title>Greeting!</title>
<style>
    body {
	width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Hello World!</h1>
<p>This server is  based on Linux CentOS Linux release 7.9.2009</p>

<p>For online documentation and support please refer to
<a href="https://github.com/Andrew-Novogrodski/MyReposity.git">My github page</a>.<br/></p>

<p><em>Thank you for visiting my server.</em></p>
</body>
</html>
EOF

    echo Start service...
    systemctl start nginx > /dev/null
    if [ $? != 0 ]; then exit 1; fi

    echo Add service to autostart...
    systemctl enable nginx > /dev/null
    if [ $? != 0 ]; then exit 1; fi

    echo Job Done
