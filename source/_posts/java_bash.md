---
title: 自动发现JAVA路径的BASH脚本
date: 2016-06-23 14:12:52
tags:
- bash
- script
- java
---

#### 自动识别JAVA路径
<!-- more -->
```
#!/bin/bash
#2016/06/23
#author:kebyn
#email:kebyn@kebyn.cc

unset choose
unset new_java_home

function java_home(){
#配置JAVA变量
if [ ! -z "$JAVA_HOME" ];then
	echo JAVA_HOME exist!
    echo $JAVA_HOME
    read -p "Do you use JAVA_HOME?y/n" -t 3 choose
    echo ""
    choose=${choose:="y"}
    if [ "$choose" == "n" -o "$choose" == "N" -o "$choose" == "NO" -o "$choose" == "No" ]
        read -p "Please input your JAVA_HOME?y/n" -t 3 new_java_home
        echo ""
        JAVA_HOME=${JAVA_HOME+${new_java_home}}
    else
        continue
    fi
else
	which java &> /dev/null

	if [ $? -eq 0 ];then
	JAVA_HOME=readlink -f $(which java)
	echo Find the JAVA !
	echo $JAVA_HOME

	else
	read -p ”请输入JAVA_HOME路径“ JAVA_HOME

	echo $JAVA_HOME
	fi
fi

JAVA_BIN=$JAVA_HOME/bin
CLASSPAHT=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
echo JAVA_HOME=$JAVA_HOME |tee >> /etc/profile
echo JAVA_BIN=$JAVA_BIN |tee >> /etc/profile
echo CLASSPAHT=$CLASSPAHT |tee >> /etc/profile
echo export JAVA_HOME JAVA_BIN CLASSPAHT >> /etc/profile
source /etc/profile
}
java_home
if [ ! -z "$JAVA_HOME" ];then
	echo JAVA_HOME set success!
    echo $JAVA_HOME
else
    echo JAVA_HOME set Failed!
    exit 1
```
