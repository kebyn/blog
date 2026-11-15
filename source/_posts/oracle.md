---
title: Oracle
date: 2016-07-20 17:12:52
tags:
- database
- oracle
- sqlplus
- command
categories:
- Database

---
1. 环境设置
```
export ORACLE_SID=orcl
export ORACLE_BASE=oracle_install_dir
export ORACLE_HOME=oracle_install_dir/oracle12c
```
2. 启动
```
oracle> startup open
bash# lsnrctl start
```
    1. startup nomount
        非安装启动，这种方式启动下可执行：重建控制文件、重建数据库,启动instance，即启动SGA和后台进程，这种启动只需要init.ora文件。
    2. startup mount dbname
        安装启动，这种方式启动下可执行：数据库日志归档、数据库恢复、重新命名一些数据库文件
        如：系统表空间或日志文件。
        执行“nomount”，然后打开控制文件
    3. startup open dbname
        先执行“nomount”，然后执行“mount”，再打开包括Redo log文件在内的所有数据库文件， 这种方式下可访问数据库中的数据。
    4. startup，等于以下三个命令
        startup nomount
        alter database mount
        alter database open
    5. startup restrict
        约束方式启动
        这种方式能够启动数据库，但只允许具有一定特权的用户访问
        非特权用户访问时，会出现以下提示：
        ERROR：
        ORA-01035: ORACLE 只允许具有 RESTRICTED SESSION 权限的用户使用
    6. startup force
        强制启动方式
        当不能关闭数据库时，可以用startup force来完成数据库的关闭
        先关闭数据库，再执行正常启动数据库命令
    7. startup pfile=参数文件名
        带初始化参数文件的启动方式
        先读取参数文件，再按参数文件中的设置启动数据库
        例：startup pfile=E:\Oracle\admin\oradb\pfile\init.ora
    8. startup EXCLUSIVE
3. 关闭
```
bash# lsnrctl stop
oracle> shutdown immediate
```
<!-- more -->
    1. Normal 需要等待所有的用户断开连接
        normal需要在所有连接用户断开后才执行关闭数据库任务，所以有的时候看起来好象命令没有运行一样！在执行这个命令后不允许新的连接
    2. Immediate 等待用户完成当前的语句
        immediate在用户执行完正在执行的语句后就断开用户连接，并不允许新用户连接。数据库并不立即关闭，而是在Oracle执行某些清除工作后才关闭（终止会话、释放会话资源)。
    3. Transactional 等待用户完成当前的事务
        transactional 在用户执行完当前事物后断开连接，并不允许新的用户连接数据库。
    4. Abort 不做任何等待，直接关闭数据库
        abort 执行强行断开连接并直接关闭数据库。直接关闭数据库，正在访问数据库的会话会被突然终止，如果数据库中有大量操作正在执行，这时执行shutdown abort后，重新启动数据库需要很长时间。
#### sqlplus中使用其他帐户连接
1. conn system/manager;
2. conn sys/change_on_install as sysdba;
3. show user 显示此时连接的是哪个帐户
#### 授权
- grant dba to USER;
- grant connect,resource to USER;
    > 用户成功创建，但是还不能正常的登录Oracle数据库系统，因为该用户还没有任何权限。如果用户能够正常登录，至少需要CREATE SESSION系统权限。
介绍几个常用角色：
    CONNECT角色，主要应用在临时用户，特别是那些不需要建表的用户，通常只赋予他们CONNECT role。CONNECT是使用Oracle的简单权限，拥有CONNECT角色的用户，可以与服务器建立连接会话（session，客户端对服务器连接，称为会话）。
    RESOURCE角色，更可靠和正式的数据库用户可以授予RESOURCE role。RESOURCE提供给用户另外的权限以创建他们自己的表、序列、过程（procedure）、触发器（trigger）、索引（index）等。
    DBA角色，DBA role拥有所有的系统权限----包括无限制的空间限额和给其他用户授予各种权限的能力。用户SYSTEM拥有DBA角色。
一般情况下，一个普通的用户（如SCOTT），拥有CONNECT和RESOURCE两个角色即可进行常规的数据库开发工作。

- drop user user_name USER;
-
> 在以超级管理员sys登陆时必须加 as sysdba 否则连接不上
如果以system 或 sys登陆时 输入 select * from emp;会出错 因为system和 sys没有emp这张表
如果此时想在不同用户下访问emp表 则需加上该表所在的用户名 例如 select * from scott.emp;

#### sqlplus中对于表的信息的查看
1. 查看所有表名,会列出该帐户权限下的所有的表名
`
    select   table_name    from   cat;
    select  table_name   from  tab;
    select  table_name   from  user_tables;
    select owner,table_name from dba_tables;
`
2. 查看表的结构
`
    describe 表名;
`
3．/ 要想继续使用上一次的正确的指令 可以直接 / 即可重复执行上一条指令
4. 查看当前用户的缺省表空间
 `
   select username,default_tablespace from user_users;
`
5. 查看当前用户的角色
`
   select * from user_role_privs;
`
6. 查看当前用户的系统权限和表级权限
`
    select * from user_sys_privs;
    select * from user_tab_privs;
`
7. 查看用户下所有的表的列属性
`
   select * from USER_TAB_COLUMNS where table_name=:table_Name;
`
8. 显示用户信息(所属表空间)
`
    select default_tablespace,temporary_tablespace
    from dba_users where username='GAME';
`
9. 查看当前用户的系统权限和表级权限
`
    select * from user_sys_privs;
    select * from user_tab_privs;
`
10. 显示当前会话所具有的权限
`
    select * from session_privs;
`
11. 显示指定用户所具有的系统权限
`
    select * from dba_sys_privs where grantee='GAME';
`
12. 显示特权用户
`
    select * from v$pwfile_users;
`
13. 显示用户信息(所属表空间)
`
    select default_tablespace,temporary_tablespace  from dba_users where username='GAME';
`
14. 显示用户的PROFILE
select profile from dba_users where username='GAME';

#### 表
1. 查看用户下所有的表
`
    select   *   from   cat;
    select   *   from   tab;
    select   table_name   from   user_tables;
`
2. 查看名称包含log字符的表
`
    select object_name,object_id from user_objects  where instr(object_name,'LOG')>0;
`
3. 查看某表的创建时间
`
    select object_name,created from user_objects where   object_name=upper('&table_name');
`
4. 查看某表的大小
`
    select sum(bytes)/(1024*1024) as "size(M)" from user_segments   where segment_name=upper('&table_name');
`
5. 查看放在Oracle的内存区里的表
`
    select table_name,cache from user_tables where instr(cache,'Y')>0;
`
#### 索引
1. 查看索引
`
    select   index_name,table_owner,table_name,tablespace_name,status   from   user_indexes   order   by   table_name;
`
2. 查看索引个数和类别
`
    select index_name,index_type,table_name from user_indexes order by table_name;
`
3. 查看索引被索引的字段
`
    select * from user_ind_columns where index_name=upper('&index_name');
`
4. 查看索引的大小
`
    select sum(bytes)/(1024*1024) as "size(M)" from user_segmentswhere segment_name=upper('&index_name');
`
#### 序列号
1. 查看序列号，last_number是当前值
`
    select * from user_sequences;
`
#### 视图
1. 查看视图的名称
`
    select   text   from   user_views   where   view_name=upper('&view_name');
    select view_name from user_views;
`
2. 查看创建视图的select语句
`
    set view_name,text_length from user_views;
    set long 2000; 说明：可以根据视图的text_length值设定set long 的大小
    select text from user_views where view_name=upper('&view_name');
`
#### 同义词
1. 查看同义词的名称
`
    select * from user_synonyms;
`
#### 约束条件
1. 查看某表的约束条件
`
    select constraint_name, constraint_type,search_condition, r_constraint_name
    from user_constraints where table_name = upper('&table_name');

    select c.constraint_name,c.constraint_type,cc.column_name
    from user_constraints c,user_cons_columns cc
    where c.owner = upper('&table_owner') and c.table_name = upper('&table_name')
    and c.owner = cc.owner and c.constraint_name = cc.constraint_name
    order by cc.position;
`
#### 存储函数和过程
1. 查看函数和过程的状态
`
    select object_name,status from user_objects where object_type='FUNCTION';
    select object_name,status from user_objects where object_type='PROCEDURE';
`
2. 查看函数和过程的源代码
`
    select text from all_source where owner=user and name=upper('&plsql_name');
`

### 系统表
ORACLE数据库的系统参数都存储在数据库中，可以通过SQLPLUS，以用户SYSYTEM进行查询。几个重要的表或者视图如下：
```
v$controlfile：控制文件的信息；
v$datafile：数据文件的信息；
v$log：日志文件的信息；
v$process：处理器的信息；
v$session：会话信息；
v$transaction：事务信息；
v$resource：资源信息；
v$sga：系统全局区的信息。
```
> 上面的视图名中的‘v$’,只是视图名字中的字符。类似于上面的视图或表还有很多，位于： $ORACLE_HOME/RDBMS/ADMIN/CATALOG.SQL文件中。
这些视图或表可以在SQLPLUS中用SELECT语句进行查询。

### 数据字典视图
```
动态字典
select  distinct    object_name from    dba_objects where   object_name like    'V$_%'  ;
系统用户字典:
select  distinct    object_name from    dba_objects where   object_name like    'DBA_%' ;
本用户的字典:
select  distinct    object_name from    dba_objects where   object_name like    'USER_%'    ;
表和列
DBA_TABLES、ALL_TABLES和USER_TABLES显示了有关数据库表的一般信息。

DBA_TAB_COLUMNS、ALL_TAB_COLUMNS和USER_TAB_COLUMNS显示了每个数据库表的列的信息。

注意：DBA_OBJECTS、ALL_OBJECTS和USER_OBJECTS显示了模式对象的信息，包括表。

完整性约束
DBA_CONSTRAINTS、ALL_CONSTRAINTS和USER_CONSTRAINST显示有关约束的一般信息。

DBA_CONS_COLUMNS、ALL_CONS_COLUMNS和USER_CONS_COLUMNS显示有关列的相关约束的一般信息。

视图
DBA_VIEWS、ALL_VIEWS和USER_VIEWS。

注意：DBA_OBJECTS、ALL_OBJECTS和USER_OBJECTS显示了模式对象的信息，包括视图。

序列
DBA_SEQUENCES、ALL_SEQUENCES和USER_SEQUENCES。

注意：DBA_OBJECTS、ALL_OBJECTS和USER_OBJECTS显示了模式对象的信息，包括序列。

同义词
DBA_SYNONYMS、ALL_SYNONYMS和USER_SYNONYMS。

注意：DBA_OBJECTS、ALL_OBJECTS和USER_OBJECTS显示了模式对象的信息，包括同义词。

索引
DBA_INDEXS、ALL_INDEXS、USER_INDEXS、DBA_IND_COLUMNS、ALL_IND_COLUMNS和USER_IND_COLUMNS。

用户
DBA_USERS。

角色
DBA_ROLES。

表空间定额
DBA_TS_QUOTAS。

配置表
DBA_PROFILES。

表空间
DBA_TABLESPACES。

数据文件
DBA_DATA_FILES。

段
DBA_SEGMENTS、USER_SEGMENT。

回滚段
DBA_ROLLBACK_SEGS、V$ROLLNAME、V$ROLLSTAT。

触发器：　　select   trigger_name,trigger_type,table_owner,table_name,status   from   user_triggers;
快照：　　select   owner,name,master,table_name,last_refresh,next   from   user_snapshots   order   by   owner,next;
同义词：　　select   *   from   syn;序列：　　select   *   from   seq;
数据库链路：　　select   *   from   user_db_links;
约束限制：　　select   TABLE_NAME,CONSTRAINT_NAME,SEARCH_CONDITION,STATUS   from   user_constraints;
本用户读取其它用户对象的权限：　　select   *   from   user_tab_privs;
本用户所拥有的系统权限：　　select   *   from   user_sys_privs;
用户：　　select   *   from   all_users   order   by   user_id;
表空间剩余自由空间情况：　　select   tablespace_name,sum(bytes),max(bytes),count(*)   from   dba_free_space   group   by   tablespace_name;
数据字典：　　select   table_name   from   dict   order   by   table_name;
锁及资源信息：　　select   *   from   v$lock;
不包括DDL锁数据库字符集：　　select   name,value$   from   props$   where   name='NLS_CHARACTERSET';
inin.ora参数：　　select   name,value   from   v$parameter   order   by   name;
SQL共享池：　　select   sql_text   from   v$sqlarea;
数据库：　　select   *   from   v$database
控制文件：　　select   *   from   V$controlfile;
重做日志文件信息：　　select   *   from   V$logfile;
来自控制文件中的日志文件信息：　　select   *   from   V$log;
来自控制文件中的数据文件信息：　　select   *   from   V$datafile;
NLS参数当前值：　　select   *   from   V$nls_parameters;
ORACLE版本信息：　　select   *   from   v$version;
描述后台进程：　　select   *   from   v$bgprocess;
查看版本信息：　　select   *   from   product_component_version;
```

```
SET AUTOTRACE OFF 此为默认值，即关闭Autotrace
SET AUTOTRACE ON EXPLAIN 只显示执行计划
SET AUTOTRACE ON STATISTICS 只显示执行的统计信息
SET AUTOTRACE ON 包含2,3两项内容
SET AUTOTRACE TRACEONLY STAT
SET AUTOTRACE TRACEONLY 与ON相似，但不显示语句的执行结果

1. set linesize 设置每行显示的长度

2. set pagesize 设置每页显示的长度 oracle中的数据是采用一页页显示的方式输出的

--定义缓冲编辑器为vi
define_editor=vi
--使DBMS_OUTPUT有效,并设置成最大buffer,并防止"吃掉"最前面的空格
set serveroutput on size 1000000 format wrapped
--设置一行可以容纳的字符数
set linesize 256
--设置一页有多少行数
set pagesize 50
--设置来回数据显示量,这个值会影响autotrace时一致性读等数据
set arraysize 5000
--页和页之间不设任何间隔
set newpage none
--LONG或CLOB显示的长度
set long 5000
--将SPOOL输出中每行后面多余的空格去掉
set trimspool on
--设置查询耗时
set timing on
--autotrace后explain plan output的格式
col plan_plus_exp format a120
--在屏幕上暂不显示输出的内容,为下面的设置sql做准备
set termout off
--设置时间格式
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
--获得用户名和global_name
col login_info_temp new_value login_info
select user||'@'||global_name login_info_temp from global_name;
--设置sql提示为"user@global_name"
set sqlprompt '&login_info SQL> '
--在屏幕上显示输出的内容
set termout on
--列格式控制
主要格式化列的显示形式。
col c1 format a1
col cc1 format a1
col c2 format a2
col cc2 format a2
col c3 format a3
col cc3 format a3
col c4 format a4
col cc4 format a4
col c5 format a5
col cc5 format a5
col c6 format a6
col cc6 format a6
col c7 format a7
col cc7 format a7
col c8 format a8
col cc8 format a8
col c9 format a9
col cc9 format a9
col c10 format a10
col cc10 format a10
col c15 format a15
col cc15 format a15
col c20 format a20
col cc20 format a20
col c30 format a30
col cc30 format a30
col c40 format a40
col cc40 format a40
col c50 format a50
col cc50 format a50
col c60 format a60
col cc60 format a60
col c70 format a70
col cc70 format a70
col c80 format a80
col cc80 format a80
col c90 format a90
col cc90 format a90
col c100 format a100
col cc100 format a100
col c150 format a150
col cc150 format a150
col c200 format a200
col cc200 format a200
col c255 format a255
col cc255 format a255
```
