---
title: git 添加 key
date: 2017-07-13 16:14:43
tags:
- git
- git key
---
```
$ ssh-add ~/.ssh/id_rsa.pub
Could not open a connection to your authentication agent.
```
You might need to start ssh-agent before you run the ssh-add command:
```
eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa
```
```
ssh -T git@github.com
ssh -Tv git@github.com
```
> [github-testing-your-ssh-connection](https://help.github.com/articles/testing-your-ssh-connection/)
