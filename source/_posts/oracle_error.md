---
title: oracle error
date: 2016-09-12 10:22:17
tags:
- oracle
- error
categories:
- Database

---

In this Document
Purpose
Troubleshooting Steps
     Section I: Steps to approach ORA-12518/TNS-12518 Error:

### Section II: Commonly Known Errors:
#### Error: 32: Broken pipe
#### Error: 11: Resource temporarily unavailable
#### Error: 12: Not enough space

<!-- more -->

---

### Error: Connection Pooling limit reached
#### Error: 2: No such file or directory
#### Error: 24: Too many open files

---

### Section III: Errors Specific to Windows
#### Error: 233: Unknown error
#### Error: 54: Unknown error
```

References

APPLIES TO:
Oracle Net Services - Version 10.1.0.2 to 11.2.0.3 [Release 10.1 to 11.2]
Information in this document applies to any platform.
PURPOSE
This article discusses about how to approach ORA-12518/TNS-12518 and troubleshoot it for the resolution.
TROUBLESHOOTING STEPS
Section I: Steps to approach ORA-12518/TNS-12518 Error:
ORA-12518/TNS-12518 indicates a problem while listener hands off the client connection to the server process or dispatcher process.TNS-12518 is logged in the listener log. The client might receive ORA-12518 or some other disconnection errors like ORA-12537. Once TNS-12518 is noted in the listener log, follow the below steps to approach and resolve this error.

Let us have a small discussion about how actually database connections are made:

In Dedicated mode, database client contacts listener and supplies the SERVICE NAME of the database. Then listener spawns a dedicated server process and hands off the client connection to this dedicated server process. TNS-12518 indicates a problem while handing off the client connection to the server process.
In Shared Server mode, database client contacts listener and supplies the SERVICE NAME of the database. Then listener hands off the client connection to one of the dispatcher configured for that service. TNS-12518 indicates a problem while handing off the client connection to the dispatcher server process.

Though this error is logged in the listener log, the listener is just the messenger, ORA-12518/TNS-12518 is mostly related to RDBMS and OS resources.
```

---

### Step 1. Is listener version compatible to the database
```
Check if you are using compatible listener version for your database version.

If the database is 8i then use 8i or 9i listeners only. 10g listeners are not compatible to work with 8i databases.
For 9i databases, 9i or 10g listeners can be used.
For 10g databases, only 10g listeners can be used.

The general rule is that use the higher version of the listener when there is a version mismatch between database and the listener.
```

### Step 2. Gather more information from listener log
```
The first place you would look for the TNS-12518 error is the listener log. Usually the listener log would be located under $ORACLE_HOME/network/log directory. You can use 'lsnrctl status' command output to look for the location of the listener log file.
$lsnrctl status
- - -
- - -
Listener Parameter File /ora10g/home_ora10g/network/admin/listener.ora
Listener Log File /ora10g/home_ora10g/network/log/listener.log
- - -
- - -
listener log gives the complete error stack and the database service name to which the client tried to connect to.
19-SEP-2007 13:55:34 * (CONNECT_DATA=(CID=(PROGRAM=)(HOST=__jdbc__)(USER=))(SERVICE_NAME=test.oracle.com)) * (ADDRESS=(PROTOCOL=tcp)(HOST=10.10.10.3)(PORT=36030)) * establish * test.oracle.com * 12518
TNS-12518: TNS:listener could not hand off client connection
 TNS-12547: TNS:lost contact
  TNS-12560: TNS:protocol adapter error
   TNS-00517: Lost contact
    Linux Error: 32: Broken pipe

In the above example, listener log shows the complete error stack, the bottom error being 32 is the OS error. It also shows that the jdbc client from IP 10.10.10.3 has tried to connect to the database service 'test.oracle.com' and failed with the error 12518.
Look for the lowest error in the stack. That is the error we have to concentrate on and try to resolve it. In the above example, the lower error is 'Linux Error: 32: Broken pipe'.
```

---

### Step 3. Is service handlers in blocked state
```
Check if the handlers are in blocked state. Check the output of the 'lsnrctl services'. Examine the status information under the database service name. From the listener log you would know which database service was affected by the 12518 error, now with the output of the 'lsnrctl services' under that service name gather more information.
Service "test.oracle.com" has 1 instance(s).
  Instance "db10g", status READY, has 2 handler(s) for this service...
    Handler(s):
      "DEDICATED" established:9 refused:0 state:ready
         LOCAL SERVER
      "D000" established:10 refused:0 current:0 max:972 state:ready
         DISPATCHER
         (ADDRESS=(PROTOCOL=tcp)(HOST=oid.mohan.com)(PORT=33487))

The highlighted state should be in 'ready' state for the connection to be successful. If the state is in 'blocked' then the connection are not possible. The state of a handler could be in blocked state in the following scenario:
i. The database parameter processes reached its value.
ii. The database is in the process of startup or shutting down.

In shared server mode, the number of dispatchers should be set according to the load that you expect. 'lsnrctl services' output shows the maximum number(max:997) of connections that the dispatcher would accept and the number connections refused (refused:0) by this dispatcher. If any connections refused by the dispatcher, then consider increasing the number of dispatchers.

If you are using PFILE edit init.ora and increase the dispatchers parameter. If you are using SPFILE you can dynamically increase the dispatchers parameter by the 'alter system set' command.
```

---

### Step 4. Is local BEQ connection successful
```
Check if local BEQ connection to the database works fine. It also verifies if the database is up and in good condition to accept the connection. If the database is down or in a hung state then a connection request to the database by the listener will not be possible.

Connect to the database server via telnet or ssh and check if a local bequeath SQL*Plus connection works. In other words, issue:
sqlplus username/password [Enter]

This connection bypasses the listener and directly connects to the database via the BEQ (bequeath) protocol. If this fails, then the TNS-12518 listener error is simply a result of the database issue.

One such error is:
ORA-12560: TNS:protocol adapter error

A possible cause for this error on Microsoft Windows servers, is that the Windows Database Service has not yet been created (common when creating a "standby" instance).
Resolution for this would be to create the Windows Service first by using the "oradim" command (see the Database Admin guide for details on oradim and service creation).
```

---

### Step 5. Is number of processes reached its limit
```
If local BEQ is successful, check the below query
SQL> select * from v$resource_limit;

RESOURCE_NAME CURRENT_UTILIZATION MAX_UTILIZATION INITIAL_AL LIMIT_VALU
-------------------- ------------------- --------------- ---------- ----------
processes 249 250 250 250
sessions 54 82 280 280
- - - - - -
- - - - - -


Verify if the processes or sessions reached its limit value. If these database parameters reached its limit value, then consider increasing it accordingly.

In the above example, the processes parameter has been set to 250. It'sMAX_UTILIZATION has reached the limit value of 250, so the processes parameter should be increased further to accomodate the number of incoming connections.

Edit the init.ora and set the processes parameter to a higher value. By default, if you just increase the processes it is enough, the sessions value would automatically be increased.
Check the alert.log for a corresponding error such as "ksvcreate" process failed, etc.  Check timestamp against listener.log timestamps for causal relationship.
```

---

### Step 6. Is OS kernal parameters configured for optimum
```
Database is operated by a single user, normally it would be 'oracle' user. At the Operating System level, there is a limit for the number of process spawned by a user. And also there is a limit for the total number of process running on the entire OS.

The Oracle Database and the newly spawned processes would be owned by the 'oracle' user. And so make sure that these values are set accordingly.On Unix these values are configured through the configurable OS kernal parameters and is specific to Operating Systems. You will have check your corresponding OS documentation for your OS.

For example for HP-UX the configurable kernal parameters are,

maxuprc  Maximum number of processes for each non-root user
nproc      Maximum number of processes on the system
```

---

### Step 7. Does alert log have any errors
```
Look in alert log and look for any errors related to memory or process during the time the error TNS-12518 occurred in the listener log. If the alert log has any memory related errors, there there is a potential memory resource issue at the OS level.

OS memory issues can be addressed by the below:
i.   Make sure that the OS has been configured with the enough Swap memory. In case of Windows it is called as Virtual Memory.
ii.  Reduce the size of SGA, thus the newly spawned server process will have some more system memory available.
iii. Reduce the PGA size, so that the newly spawned server process would occupy less memory.
iv. If you are in DEDICATED mode, try switching to MTS mode.

To address memory issue for 32-bit Windows: Refer Note 371983.1
If there are any memory or process related error in the alert log during the time the TNS-12518 is logged in the listener log, then those errors in the alert log should be focused on and should be solved at first. Because, the errors in the alert log is the base error for the TNS-12518 in the listener log.

However, the errors in the alert logs are not being discussed in this article, they are out of the scope of this article.
Step 8. If using a statically defined SID_DESC in the listener.ora file for your sid, ensure that it is configured properly.
A common mistake is to include a (PROGRAM=EXTPROC) parameter:
  (SID_LIST=
    (SID_DESC =
      (GLOBAL_DBNAME = ORCL.oracle.com)
      (SID_NAME = ORCL)
      (PROGRAM=extproc)
      (ORACLE_HOME = D:\oracle\product\10.2.0\db_1)))
This misconfiguration occurs when the PLSExtproc SID_DESC is copied, pasted and edited in the listener.ora file.  The inclusion of the PROGRAM line will cause an ORA-12518 to be returned to the client.  Here's the corrected SID_DESC for our example SID:
  (SID_LIST=
     (SID_DESC =
     (GLOBAL_DBNAME = ORCL.oracle.com)
     (SID_NAME = ORCL)
     (ORACLE_HOME = D:\oracle\product\10.2.0\db_1)))
Section II: Commonly Known Errors:

This section lists some of the known and reported errors. It is also recommended that you refer the Section I above for a generic troubleshooting approach to the error TNS-12518.

Below shows example error stack that can be found in the listener log. The last line in the error stack shows the actual operating system name. Depending on the OS, only the operating system name would be different. For example, if you encounter error 32: Broken pipe, according to the OS, the last line in the error stack would be different only by the OS name, as shown below.

Solaris Error: 32: Broken pipe
HPUX Error: 32: Broken pipe
Linux Error: 32: Broken pipe
```

---

##### Error: 32: Broken pipe
```
Error stack in listener log:

TNS-12518: TNS:listener could not hand off client connection
 TNS-12547: TNS:lost contact
   TNS-12560: TNS:protocol adapter error
     TNS-00517: Lost contact
       IBM/AIX RISC System/6000 Error: 32: Broken pipe


Cause:
The error 32 indicates the communication has been broken while the listener is trying to hand off the client connection to the server process or dispatcher process.

Action:
1.  One of reason would be processes parameter being low, and can be verified by the v$resource_limit view.
2. In Shared Server mode, check the 'lsnrctl services' output and see if the dispatcher has refused any connections, if so, then consider increasing the number of dispatchers.
3. Check the alert log for any possible errors.
4. Memory resource is also another cause for this issue. Check the swap, memory usage of the OS.
5. If RAC/SCAN or listener is running in separate home, check the following note:

Note: 1069517.1  ORA-12537 or TNS-12518 if Listener (including SCAN Listener) and Database are Owned by Different OS User
```

---

##### Error: 11: Resource temporarily unavailable
```
Error stack in listener log:
TNS-12518: TNS:listener could not hand off client connection
 TNS-12549: TNS:operating system resource quota exceeded
  TNS-12560: TNS:protocol adapter error
   TNS-00519: Operating system resource quota exceeded
    IBM/AIX RISC System/6000 Error: 11: Resource temporarily unavailable


Cause:
As the error indicates operating system resource has exceeded.

Action:
1. Increase the appropriate OS kernal parameters for 'maximum number of processes allowed per user'.
For example for HP-UX the parameters are maxuprc and nproc.
```

---

##### Error: 12: Not enough space
```
Error stack in listener log:
 TNS-12518: TNS:listener could not hand off client connection
   TNS-12549: TNS:operating system resource quota exceeded
     TNS-12560: TNS:protocol adapter error
       TNS-00519: Operating system resource quota exceeded
         IBM/AIX RISC System/6000 Error: 12: Not enough space


Cause:
This is a memory related issue. The error indicates that there is not enough memory available to spawn and hand off the client connections.
Typical problems are:
- Out of system memory / swap
- Out of process slots in the process table
- Streams resources depleted
- Out of File Handles
- sga memory usage


Action:
1. Check in the alert log for any possible memory related error.
2. Increase swap/Virtual memory if possible the available memory.
3. SGA and PGA can be reduced to address the memory consumption.
4. MTS mode can be used to reduce the amount of process and memory consumption.
```

---

##### Error: Connection Pooling limit reached
```
Error stack in listener log:
 TNS-12518 TNS:listener could not hand off client connection
  TNS-12564 TNS:connection refused
   TNS-12602 TNS: Connection Pooling limit reached


Action:
1. Try increasing initial number of dispatchers.
```

---

##### Error: 2: No such file or directory
```
Error stack in listener log:
 TNS-12518: TNS:listener could not hand off client connection
  TNS-12560: TNS:proto adapter error
   TNS-00530: Proto adapter error
    32-bit Windows Error: 2: No such file or directory


Error Description:
ERROR_FILE_NOT_FOUND
2
The system cannot find the file specified.

Cause:
This indicates the database service is not actually available


Action:
1.Verify if the intended database really up and accepting local BEQ connections.
```

---

##### Error: 24: Too many open files
```
Error stack in listener log:
    TNS-12518: TNS:listener could not hand off client connection
      TNS-12560: TNS:protocol adapter error
       TNS-00530: Protocol adapter error
        Linux Error: 24: Too many open files

or

    TNS-12518: TNS:listener could not hand off client connection
      TNS-12560: TNS:protocol adapter error
       TNS-00530: Protocol adapter error
        Solaris Error: 24: Too many open files
Error Description:
 Out of file descriptors
Cause:
Can be caused by the following unpublished defect:
BUG 13078786 - LISTENER GOES DOWN SUDDENLY W/ LINUX ERROR: 32: BROKEN PIPE
Action:

See Note 1527483.1  11.2 : ORA-12518 Listener Hangs and Reports "Too Many Open Files"

Use prescribed workaround OR apply one-off patch to your environment if available.
```

---

##### Section III: Errors Specific to Windows
```
It is also recommended that you refer the Section I above for a generic troubleshooting approach to the error TNS-12518.

This section briefly describes about the errors that are encountered on Windows Operating System. TNS-12518 most commonly occurs on 32-bit OS due to its memory constraint, however TNS-12518 can occur on 64-bit OS as well. See Note 873752.1 for more information on Windows memory addressing and the 3GB switch.
```

---

##### Error: 233: Unknown error
```
Error stack in listener log:
 TNS-12518: TNS:listener could not hand off client connection
  TNS-12560: TNS:protocol adapter error
   TNS-00530: Protocol adapter error
    32-bit Windows Error: 233: Unknown error


Error Description:
ERROR_PIPE_NOT_CONNECTED
233
No process is on the other end of the pipe.

Cause:
The communication has been broken while the listener is trying to hand off the client connection to the server process or dispatcher process.


Action:
Refer Note 371983.1
```

---

##### Error: 54: Unknown error
```
Error stack in listener log:
 TNS-12518: TNS:listener could not hand off client connection
  TNS-12571: TNS:packet writer failure
   TNS-12560: TNS:protocol adapter error
    TNS-00530: Protocol adapter error
      32-bit Windows Error: 54: Unknown error


 Error Description:
ERROR_NETWORK_BUSY
54
0x36
The network is busy.


Cause:
This indicates a bottleneck at the network layer(TCP/IP).


Action:
1.Try increasing dispatchers and shared servers.
```

---

> 转载ROUBLESHOOTING GUIDE TNS-12518 TNS listener could not hand off client connection (文档ID 550859.1)
