## 简介
xyblog是一个基于ruby的开源博客程序，采用markdown编辑器，提供后台管理功能，集成微博登录和分享接口，比较有趣。

个人网站：[http://www.nebula.pub](http://www.nebula.pub)

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

如果有连接问题，可将Gemfile中第一行替换为`source 'https://gems.ruby-china.org'`
详细参考[Ruby China](https://gems.ruby-china.org/)

#### 配置database.yml

```bash
$ cp config/database.example.yml config/database.yml
```

修改`config/database.yml`文件
- `database`：数据库名
- `username`：数据库用户
- `password`：用户密码
- 其他可保持默认

#### 配置app_config.yml

```bash
$ cp config/app_config.example.yml config/app_config.yml
```

修改`config/app_config.yml`
- `session_secret`：执行`$ bundle exec rake secret`的结果
- `blog_search`：是否开启全文检索功能
- 其他参数根据需求修改

#### 配置数据库
进入mysql手动创建数据库

```sql
mysql> create database xyblog;
```

执行迁移

```bash
$ bundle exec rake ar:migrate
$ bundle exec rake db:seed
```

#### 配置unicorn
修改`config/unicorn.rb`
- `app_dir`：程序目录
- `worker_processes`：一般为cpu核数

可执行`$ cat /proc/cpuinfo|grep "processor"|wc -l`查看

修改`deploy/unicorn`
- `APP_ROOT`：程序目录

移动文件到/etc/init.d/

```bash
$ cp deploy/unicorn /etc/init.d/xyblog
```

#### 配置nginx

修改`deploy/nginx.conf`
- `worker_processes`：一般为cpu核数
- `server_name`：域名
- `root`：程序public目录

移动到nginx config目录

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