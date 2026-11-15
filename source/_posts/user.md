---
title: useradd
date: 2015-06-09 11:22:17
tags:
- command
- useradd
categories:
- Linux

---

## useradd –help

### Usage: useradd \[options\] LOGIN

#### Options:

```
-b, --base-dir BASE_DIR       base directory for the home directory of the
                              new account
-c, --comment COMMENT         GECOS field of the new account
-d, --home-dir HOME_DIR       home directory of the new account
-D, --defaults                print or change default useradd configuration
      查看预设值
-e, --expiredate EXPIRE_DATE  expiration date of the new account
      The date on which the user account will be disabled. The date is specified in the format YYYY-MM-DD.

      If not specified, useradd will use the default expiry date specified by the EXPIRE variable in /etc/default/useradd, or an empty string (no expiry) by default.

-f, --inactive INACTIVE       password inactivity period of the new account
      The number of days after a password expires until the account is permanently disabled. A value of 0 disables the account as soon as the password has expired,
      and a value of -1 disables the feature.

      If not specified, useradd will use the default inactivity period specified by the INACTIVE variable in /etc/default/useradd, or -1 by default.
-g, --gid GROUP               name or ID of the primary group of the new
                              account
-G, --groups GROUPS           list of supplementary groups of the new
                              account
-h, --help                    display this help message and exit
-k, --skel SKEL_DIR           use this alternative skeleton directory
-K, --key KEY=VALUE           override /etc/login.defs defaults
-l, --no-log-init             do not add the user to the lastlog and
                              faillog databases
-m, --create-home             create the user's home directory
      強制！要建立使用者家目錄！(一般帳號預設值)
-M, --no-create-home          do not create the user's home directory
      強制！不要建立使用者家目錄！(系統帳號預設值)
-N, --no-user-group           do not create a group with the same name as
                              the user
-o, --non-unique              allow to create users with duplicate
                              (non-unique) UID
-p, --password PASSWORD       encrypted password of the new account
-r, --system                  create a system account
-s, --shell SHELL             login shell of the new account
-u, --uid UID                 user ID of the new account
-U, --user-group              create a group with the same name as the user
-Z, --selinux-user SEUSER     use a specific SEUSER for the SELinux user mapping
```

<!-- more -->

* * *

### userdel –help

#### Usage: userdel \[options\] LOGIN

#### Options:

```
-f, --force                   force removal of files,
  This option forces the removal of the user account, even if the user is still logged in. It also forces userdel to remove the user´s home directory and mail
         spool, even if another user uses the same home directory or if the mail spool is not owned by the specified user. If USERGROUPS_ENAB is defined to yes in
         /etc/login.defs and if a group exists with the same name as the deleted user, then this group will be removed, even if it is still the primary group of another
         user.

         Note: This option is dangerous and may leave your system in an inconsistent state.
                          even if not owned by user
-h, --help                    display this help message and exit
-r, --remove                  remove home directory and mail spool
-Z, --selinux-user            remove SELinux user from SELinux user mapping
```

* * *

### chage –help

#### Usage: chage \[options\] \[LOGIN\]

#### Options:

```
-d, --lastday LAST_DAY        set date of last password change to LAST_DAY
      Set the number of days since January 1st, 1970 when the password was last changed. The date may also be expressed in the format YYYY-MM-DD (or the format more
         commonly used in your area).

-E, --expiredate EXPIRE_DATE  set account expiration date to EXPIRE_DATE
-h, --help                    display this help message and exit
-I, --inactive INACTIVE       set password inactive after expiration
                              to INACTIVE
-l, --list                    show account aging information
-m, --mindays MIN_DAYS        set minimum number of days before password
                              change to MIN_DAYS
-M, --maxdays MAX_DAYS        set maximim number of days before password
                              change to MAX_DAYS
-W, --warndays WARN_DAYS      set expiration warning days to WARN_DAYS
```

### \[1.153\_old\]$ sudo cat /etc/passwd |awk -F: ‘ $3 > 500 ‘

```
nfsnobody:x:65534:65534:Anonymous NFS User:/var/lib/nfs:/sbin/nologin
mysql:x:501:501::/home/mysql:/bin/bash
svn:x:502:502::/home/svn:/bin/bash
user01:x:503:0::/home/user01:/bin/bash
user02:x:504:0::/home/user02:/bin/bash
user03:x:505:0::/home/user03:/bin/bash
user04:x:506:0::/home/user04:/bin/bash
user05:x:509:0::/home/user05:/bin/bash
user06:x:512:0::/home/user06:/bin/bash
user07:x:513:0::/home/user07:/bin/bash
user08:x:514:514::/home/user08:/bin/bash
user09:x:515:0::/home/user09:/bin/bash
user10:x:516:0::/home/user10:/bin/bash
user11:x:517:0::/home/user11:/bin/bash
user12:x:518:0::/home/user12:/bin/bash
```

* * *

### useradd.sh

```
#!/bin/bash
unset name
unset name_list
unset i

groupadd -g 501 mysql
useradd -u 501 -g 501 mysql
echo '<redacted>' | passwd --stdin mysql
#chage -d 0 mysql

groupadd -g 502 svn
useradd -u 502 -g 502 svn
echo '<redacted>' | passwd --stdin svn
#chage -d 0 svn

groupadd -g 503 user01
useradd -u 503 -g 0 user01
passwd user01
chage -d 0 user01

#用户组从503开始
i=503
name_list=$(cat list.txt | awk -F: ' $3>503 {print $1}')

for name in $name_list;do
    if [ "$name" = "nfsnobody" ];then
        continue
    fi
    #groupadd -g $i $name
    #useradd -u $i -g $i $name

    useradd -u $i -g 0 $name
    echo "$name" | passwd --stdin $name
    chage -d 0 $name
    i=$[ i + 1 ]
done

unset $name
unset $name_id
read -"请输入取消root组的用户名"  $name
name_id=$(id -u $name)
groupadd -g $name_id $name
usermod -g $name_id $name
cat /etc/passwd |awk -F: ' $3 > 500 '
```
