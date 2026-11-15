---
title: parted
date: 2015-07-17 09:22:17
tags:
- command
- parted
---

### parted –help

###### Usage: parted \[OPTION\]… \[DEVICE \[COMMAND \[PARAMETERS\]…\]…\]

Apply COMMANDs with PARAMETERS to DEVICE. If no COMMAND(s) are given, run in  
interactive mode.

##### OPTIONs:

```
-h, --help                      displays this help message
-l, --list                      lists partition layout on all block devices
-m, --machine                   displays machine parseable output
-s, --script                    never prompts for user intervention
-v, --version                   displays the version
-a, --align=[none|cyl|min|opt]  alignment for new partitions
```

<!-- more -->

* * *

###### COMMANDs:

```
    align-check TYPE N                        check partition N for TYPE(min|opt)

    alignment

    check NUMBER                             do a simple check on the file system
    
    cp [FROM-DEVICE] FROM-NUMBER TO-NUMBER   copy file system to another partition

    help [COMMAND]                           print general help, or help on
          
	COMMAND

    mklabel,mktable LABEL-TYPE               create a new disklabel (partition
          table) label-type

          malable Create a new disklabel (partition table) of label-type.   label-
                  type  should  be  one  of  "bsd",  "dvh",  "gpt", "loop", "mac",
                  "msdos", "pc98", or "sun".

          mktable mbr gpt
          
    mkfs NUMBER FS-TYPE                      make a FS-TYPE file system on
          
	partition NUMBER

	partition fs-type

                       Make  a  filesystem  fs-type on partition. fs-type can be one of
                       "fat16", "fat32", "ext2", "linux-swap", or "reiserfs".

    mkpart PART-TYPE [FS-TYPE] START END     make a partition
    
    mkpartfs PART-TYPE FS-TYPE START END     make a partition with a file system

	Make a part-type partition with filesystem fs-type beginning  at
                       start  and  ending at end (by default in megabytes).  Using this
                       command is discouraged.  Instead use mkpart to create  an  empty
                       partition,  and then use external tools like mke2fs(8) to create
                       the filesystem.

    move NUMBER START END                    move partition NUMBER

    name NUMBER NAME                         name partition NUMBER as NAME

    print [devices|free|list,all|NUMBER]     display the partition table,

          available devices, free space, all found partitions, or a particular
          partition

    quit                                     exit program

    rescue START END                         rescue a lost partition near START
          and END

    resize NUMBER START END                  resize partition NUMBER and its file
          system

    rm NUMBER                                delete partition NUMBER

    select DEVICE                            choose the device to edit

    set NUMBER FLAG STATE                    change the FLAG on partition NUMBER

    toggle [NUMBER [FLAG]]                   toggle the state of FLAG on partition

          NUMBER

    unit UNIT                                set the default unit to UNIT

    version                                  display the version number and
copyright information of GNU Parted
```
