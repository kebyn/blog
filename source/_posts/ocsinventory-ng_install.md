---
title: ocs_ng 安装
date: 2017-07-20 14:35:43
tags:
- git
- git key
---
1. Unpack it.
```
tar –xvzf Ocsinventory-Agent-2.0.x.tar.gz
cd Ocsinventory-Agent-2.0.x
```
<!-- more -->

2. Check perl configuration with the script Makefile.PL. Its looks at the configuration of Perl, machine, libraries ... and it generates the Makefile. During this step, we will create a temporary environment variable to install agent non-interactively.
```
        env PERL_AUTOINSTALL=1 perl Makefile.PL
```
Exemple :
        Please install Crypt::SSLeay if you want to use SSL.
        Please install nmap or ipdiscover if you want to use the network discover feature.
        Please install Proc::Daemon and Proc::PID::File if you want to use the daemon monde.
3. Compilation
```
        make
        make install
```

[引用](http://wiki.ocsinventory-ng.org/index.php?title=Documentation:UnixAgent)
