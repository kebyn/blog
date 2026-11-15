---
title: DB2常用命令
date: 2016-09-06 15:23:33
tags:
- database
- DB2
- sql
- command
---

##### 启动实例(db2inst1)：实例相当于informix中的服务
```
    db2start
```
##### 停止实例(db2inst1)：
```
    db2stop
```
##### 列出所有实例(db2inst1)
```
    db2ilist
```
##### 列出当前实例：
```
    db2 get instance
```
<!-- more -->

##### 察看示例配置文件：
```
    db2 get dbm cfg|more
```
##### 更新数据库管理器参数信息：
```
    db2 update dbm cfg using para_name para_value
```
##### 创建数据库：
```
    db2 create db test
```
##### 察看数据库配置参数信息
```
    db2 get db cfg for test|more
```
##### 更新数据库参数配置信息
```
    db2 update db cfg for test using para_name para_value
```
##### 删除数据库：
```
    db2 drop db test
```
##### 连接数据库
```
    db2 connect to test
```
##### 列出所有表空间的详细信息。
```
    db2 list tablespaces show detail
```
##### 列出容器的信息
```
    db2 list tablespace containers for tbs_id show detail
```
##### 创建表：
```
    db2 ceate table tb1(id integer not null,name char(10))
```
##### 列出所有表
```
    db2 list tables
```
##### 插入数据：
```
    db2 insert into tb1 values(1,’sam’);
    db2 insert into tb2 values(2,’smitty’);
```
##### 查询数据：
```
    db2 “select * from tb1”
```
##### 删除数据：
```
    db2 delete from tb1 where id=1
```
##### 创建索引：
```
    db2 create index idx1 on tb1(id);
```
##### 创建视图：
```
    db2 create view view1 as select id from tb1
```
##### 查询视图：
```
    db2 select * from view1
```
##### 节点编目
```
    db2 catalog tcp node node_name remote server_ip server         server_port
```
##### 察看端口号
```
    db2 get dbm cfg|grep SVCENAME
```
##### 节点的附接
```
    db2 attach to node_name
```
##### 察看本地节点
```
    db2 list node direcotry
```
##### 节点反编目
```
    db2 uncatalog node node_name
```
##### 数据库编目
```
    db2 catalog db db_name as db_alias at node node_name
```
##### 察看数据库的编目
```
    db2 list db directory
```
##### 连接数据库
```
    db2 connect to db_alias user user_name using user_password
```
##### 数据库反编目
```
    db2 uncatalog db db_alias
```
##### 导出数据
```
    db2 export to myfile of ixf messages msg select * from tb1
```
##### 导入数据
```
    db2 import from myfile of ixf messages msg replace into tb1
```
##### 导出数据库的所有表数据
```
    db2move test export
```
##### 生成数据库的定义
```
    db2look -d db_alias -a -e -m -l -x -f -o db2look.sql
```
##### 创建数据库
```
    db2 create db test1
```
##### 生成定义
```
    db2 -tvf db2look.sql
```
##### 导入数据库所有的数据
```
    db2move db_alias import
```
##### 重组检查
```
    db2 reorgchk
```
##### 重组表tb1
```
    db2 reorg table tb1
```
##### 更新统计信息
```
    db2 runstats on table tb1
```
##### 备份数据库test
```
    db2 backup db test
```
##### 恢复数据库test
```
    db2 restore db test
```
##### 拥有实例的所有程序列表
```
    db2 list application
```
##### 断开数据库连接,同时退出
```
    db2 terminate
```
##### 查看数据表结构
```
    db2 “describe select * from ggwdxtcs”
```
##### 启动命令界面
```
    db2cmd
```
##### 查看帮助
```
    db2 ? *
```
##### 连接数据库
```
    db2 connect to user using
```
##### 查看数据库实例
```
    db2ilist
```
##### 停止数据库应用
```
    db2 force applications all
```
##### 查看表空间
```
    db2 list tablespaces show detail
```
##### 查看表是否有记录
```
    db2 select count(*) from
```
##### 从文本导入到数据库表中
```
    db2 import from #####*.ixf of ixf modified by forcein commitcount 1000 insert into
```
##### 查看sql语句错误解释
```
    db2 ? sql########## ##########为四位出错编码，不足位前补0
    db2 ? “sqlstate”
    db2 ? sqlstate=42884
    db2 “select * from syscat.functions” |grep –i rtrim
    db2 “select * from syscat.indexes”
```
##### 表增加列
```
    db2 alter table 表名 add column 字段名 varchar(4)(字段类型）
```
##### 修改表里的字段
```
    db2 update 表名 set 字段名='xxx' where .....
```