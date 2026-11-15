---
title: Python中常用模块
date: 2016-06-17 12:12:52
tags:
- python
- 进度条
- sys
- os
---

##### sys.stdout 加time可以写进度条百分百

```
for i in range(100):  
    # num += "#"  
    sys.stdout.write('\r')  ##意思是打印在清空  
    i1 = i / 100  
    sys.stdout.write("%s%% | %s" % (int(i1 * 100), int(i1 *100) * "#"))  
    sys.stdout.flush()  
    time.sleep(0.3)
```

<!-- more -->

##### sys结合os，把当前路径，或者需要的路径添加到模块搜索路径

```
path = sys.path.append(os.path.join(os.path.dirname(os.path.dirname(__file__))))

import sys  
import os  
a = os.path.dirname(__file__)  
b = 'bin'  
c = os.path.join(a,b)  
sys.path.append(c)  
print(sys.path)
```

```
sys.argv                            命令行参数list,第一个元素是程序员本事路径  
sys.exit(n)                         退出程序，正常退出时exit(0)  
sys.version                         获取python解释程序的版本信息  
sys.maxint                          最大的int值（3.0取消）  
sys.path                            返回模块的搜索路径，初始化时使用PYTHONPATH环境变量的值  
sys.platform                        返回操作系统平台的名称  
sys.stdout                          输出相关内容  
sys.stdin                           输入相关内容
os.getcwd()                         获取当前工作目录，即当前python脚本工作的目录路径  
os.chdir("dirname")                 改变当前脚本工作目录，相当于shell下cd  
os.curdir                           返回当前目录（"."）  
os.pardir                           获取当前目录的父目录字符串名（".."）  
os.makedir          
os.makedirs('dir1/dir2')            可生成多成递归目录  
os.removedirs('dirname1')           若目录为空，则删除，并递归到上一层目录，如若也为空，则删除，依此类推  
os.mkdir('dirname')                 生成单级目录；相当于shell中mkdir dirname  
os.rmdir('dirname')                 删除单级空目录，若目录不为空则无法删除，报错；相当于shell中的rmdir dirname  
os.listdir('dirname')               列出指定目录下的所有文件和子目录，包括隐藏文件，并以列表方式打印  
os.remove()                         删除一个文件  
os.rename("oldname","new")          重命名文件/目录  
os.stat('path/filename')            获取文件/目录信息  
os.seq                              操作系统特定的路径分隔符，win下位"\\",linux下位"/"   
os.pathseq                          用于分割文件路径的字符串  
os.name                             字符串指示当前使用平台。win->'nt';linux->'posix'  
os.system("bash command")           运行shell命令，直接显示  
os.environ                          获取环境变量  
os.path.abspath(path)               返回path规范化的绝对路径  
os.path.split(path)                 将path分割和文件名二元组返回  
os.path.dirname(path)               返回path的目录。其实就是os.path.split(path) 的第一元素  
os.path.basename(path)              返回path最后的文件名。如果path以/或\结尾，那么就会返回空值。即os.path.split(path) 的第二个元素  
os.path.exists(path)                如果path存在，返回True；如果path不存在，返回False  
os.path.isabs(path)                 如果path是绝对路径，返回True  
os.path.isfile(path)                如果path是一个存在的文件，返回True。否则返回False  
os.path.isdir(path)                 如果path是一个存在的目录，则返回True。否则返回False  
os.path.join(path1[,path2[,...]])   将多个路径组合后返回，第一个绝对路径之前的参数将被忽略  
os.path.getatime(path)              返回path所指向的文件或者目录的最后存取时间  
os.path.getmtime(path)              返回path所指向的文件或目录的最后修改时间  
os.sep                              更改操作系统中的路径分隔符。  
os.getcwd()                         获取当前路径，这个在Python代码中比较常用。  
os.listdir()                        列出当前目录下的所有文件和文件夹。  
os.remove()                         方法可以删除指定的文件。  
os.system()                         方法用来运行shell命令。  
os.chdir()                          改变当前目录，到指定目录中。
```
