## 简介
xyblog是一个基于ruby的开源博客程序，采用markdown编辑器，提供后台管理功能，集成微博登录和分享接口，比较有趣。

个人网站：[http://www.nebula.pub](http://nebula.pub)

## 系统要求
- git 2.0.0
- ruby 1.9+
- mysql 5.6，不推荐5.7（由于新版一些特性，部署过程会报错）
- memcached 缓存系统
- elasticsearch 搜索引擎
- nginx 代理服务器

## 部署过程
#### 安装rubygem

```bash
$ cd xyblog_dir
$ gem install bundle
$ bundle install
```

如果有连接问题，考虑修改Gemfile中source 为```https://gems.ruby-china.org```

#### 配置database.yml

```bash
$ cp config/database.example.yml config/database.yml
$ vim config/database.yml
```

需要修改database, username, password，其他可保持默认

#### 配置app_config.yml

```bash
$ bundle exec rake secret
$ cp config/app_config.example.yml config/app_config.yml
$ vim config/app_config.yml
```

session_secret 修改为 rake secret的的结果，开启搜索功能请将blog_search值改为true，其他参数按需要需要修改。

#### 数据库
手动创建数据库

```bash
$ bundle exec rake ar:migrate
$ bundle exec rake db:seed
```
#### 配置unicorn

```bash
$ vim config/unicorn.rb
```

修改app_dir为项目目录，修改worker_processes为逻辑cpu个数，可通过```$ cat /proc/cpuinfo| grep "processor"| wc -l```查看

```bash
$ vim deploy/unicorn
```

修改APP_ROOT为项目目录，移动到init.d/

```bash
$ cp deploy/unicorn /etc/init.d/xyblog
```
#### 配置nginx

```bash
$ vim deploy/nginx.conf
```

修改worker_processes为逻辑cpu个数，修改server_name和root地址，并移动到nginx目录

```bash
$ cp deploy/nginx.conf /usr/local/nginx/conf/nginx.conf
```

## 启动程序

```bash
$ memcached -d
$ /etc/init.d/mysql start
$ /etc/init.d/xyblog start
$ /usr/local/nginx/sbin/nginx
```

最后切换用户启动 elasticsearch
```bash
$ cd elasticsearch-$version
$ ./bin/elasticsearch -d
```