## 简介
xyblog是一个基于ruby的开源博客程序，采用markdown编辑器，提供后台管理功能，集成微博登录和分享接口，非常有趣。

项目地址：[https://github.com/wxy1106/xyblog](https://github.com/wxy1106/xyblog)

## 系统要求
点击列表查看详细安装文档
- [git 2.0.0](http://www.nebula.pub/blog/4/git-install)
- [ruby 1.9+](http://www.nebula.pub/blog/3/ruby-install)
- [mysql 5.6](http://www.nebula.pub/blog/5/mysql-install)，不推荐5.7（由于新版一些特性，部署过程会报错）
- [memcached](http://memcached.org/downloads) 缓存系统
- [elasticsearch](https://www.elastic.co/downloads/elasticsearch) 搜索引擎
- [nginx](http://nebula.pub/blog/6/nginx-install) 代理服务器

## 部署过程
1. 安装rubygem

    ```bash
    $ cd xyblog_dir
    $ gem install bundle
    $ bundle install
    ```

    如果有连接问题，可将Gemfile中第一行替换为`source 'https://gems.ruby-china.org'`

    详细参考[Ruby China](https://gems.ruby-china.org/)

2. 配置database.yml

    ```bash
    $ cp config/database.example.yml config/database.yml
    ```

    修改`config/database.yml`文件
    - `database`：数据库名
    - `username`：数据库用户
    - `password`：用户密码
    - 其他可保持默认

3. 配置app_config.yml

    ```bash
    $ cp config/app_config.example.yml config/app_config.yml
    ```

    修改`config/app_config.yml`
    - `session_secret`：执行`$ bundle exec rake secret`的结果
    - `blog_search`：是否开启全文检索功能
    - 其他参数根据需求修改

4. 配置数据库
    进入mysql手动创建数据库

    ```sql
    mysql> create database xyblog;
    ```

    执行迁移

    ```bash
    $ bundle exec rake ar:migrate
    $ bundle exec rake db:seed
    ```

5. 配置unicorn
    修改`config/unicorn.rb`
    - `app_dir`：程序目录
    - `worker_processes`：一般为cpu核数`$nproc`


    修改`deploy/unicorn`
    - `APP_ROOT`：程序目录

    移动文件到/etc/init.d/

    ```bash
    $ cp deploy/unicorn /etc/init.d/
    ```

6. 配置nginx

    修改`deploy/nginx.conf`
    - `worker_processes`：一般为cpu核数
    - `server_name`：域名
    - `root`：程序public目录

    复制到nginx config目录

    ```bash
    $ cp deploy/nginx.conf /usr/local/nginx/conf/nginx.conf
    ```

    复制启动脚本

    ```
    $ cp deploy/nginx /etc/init.d/
    $ chmod 755 /etc/init.d/nginx
    ```

## 启动程序

```bash
$ memcached -d
$ /etc/init.d/mysql start
$ /etc/init.d/xyblog start
$ /etc/init.d/nginx start
```

最后切换用户启动 elasticsearch

```bash
$ cd elasticsearch-$version
$ ./bin/elasticsearch -d
```