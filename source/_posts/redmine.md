---
title: redmine
date: 2017-06-13 12:06:37
tags:
- redmine
- 403
- issus
categories:
- Web

---
1. ##__403__
__There are no projects with trackers for which you can create an issue!__
   1. Issue statuses问题状态
     - 设置问题状态
   2. Trackers跟踪标签
     - 设置跟踪标签,跟踪标签中需要设置问题状态
   2. Roles and permissions角色和权限
     - 设置跟踪标签的权限，给予new issue权限
<!-- more -->
2. ## Mariadb
  1. cmake选项
    - [https://dev.mysql.com/doc/refman/5.7/en/source-configuration-options.html](https://dev.mysql.com/doc/refman/5.7/en/source-configuration-options.html)
  2.  下载
    - [https://downloads.mariadb.org/](https://downloads.mariadb.org/)
  3. 初始化
    - [https://dev.mysql.com/doc/refman/5.7/en/installing-source-distribution.html](https://dev- .mysql.com/doc/refman/5.7/en/installing-source-distribution.html)
  4. 授权
  ```
          Your MariaDB connection id is 10
          Server version: 10.2.6-MariaDB Source distribution

          Copyright (c) 2000, 2017, Oracle, MariaDB Corporation Ab and others.

          Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

          MariaDB [(none)]> CREATE DATABASE redmine CHARACTER SET utf8;
          Query OK, 1 row affected (0.00 sec)

          MariaDB [(none)]> CREATE USER 'redmine'@'localhost' IDENTIFIED BY 'redmine';
          Query OK, 0 rows affected (0.00 sec)

          MariaDB [(none)]> GRANT ALL PRIVILEGES ON redmine.* TO 'redmine'@'localhost';
          Query OK, 0 rows affected (0.00 sec)

          MariaDB [(none)]> flush privileges;
          Query OK, 0 rows affected (0.00 sec)

          MariaDB [(none)]> \q
          Bye
  ```

3. ## Ruby
  1. rbenv
    - 安装
        - rbenv
        ```
              $ git clone https://github.com/rbenv/rbenv.git ~/.rbenv
              $ cd ~/.rbenv && src/configure && make -C src
        ```
        - ruby-build
        ```
              $ git clone https://github.com/rbenv/ruby-build.git
              $ cd ruby-build
              $ ./install.sh
        ```
    - rbenv环境变量
        ```
            # rbenv - setting
            export PATH="$HOME/.rbenv/bin:$PATH"

            # to detect .rbenv-version
            eval "$(rbenv init -)"

            # prod
            export RAILS_ENV="production"
        ```
  2. 安装依赖
        ```
          gem install bundler
          sudo apt-get install libmagickwand-dev imagemagick
          gem install rmagick -v '2.16.0'
          gem install json -v '1.8.3'
          bundle install --without development test
          bundle exec rake generate_secret_token
          bundle exec rake db:migrate
          REDMINE_LANG=zh bundle exec rake redmine:load_default_data
        ```

  3. 启动rails
```
    bundle exec rails server webrick -e production
    bundle exec rails server webrick -b xxx.xxx.xxx.xxx -e production
    bundle exec rails server webrick -p 3000 -e production

```
