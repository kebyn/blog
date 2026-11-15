---
title: Linux 宕机急救
date: 2017-09-29 17:37:43
tags:
- crash
- SysRq
---
- 在一般 Linux 當機的狀況下，若要重新啟動系統，可以按住 Alt + SysRq 兩個鍵，然後依序按下以下幾個指令鍵：
```
r e i s u b
```
<!-- more -->
- 系统宕机时救助
  - [Magic_SysRq_key](https://en.wikipedia.org/wiki/Magic_SysRq_key#Commands)
  - [safe-reboot-of-linux-using-magic-sysrq-key](https://blog.gtwang.org/linux/safe-reboot-of-linux-using-magic-sysrq-key/)
- 内存故障
```
root@server-60:~# grep "[0-9]" /sys/devices/system/edac/mc/mc*/csrow*/ch*_ce_count
/sys/devices/system/edac/mc/mc0/csrow0/ch0_ce_count:0
/sys/devices/system/edac/mc/mc0/csrow0/ch1_ce_count:1
/sys/devices/system/edac/mc/mc0/csrow0/ch2_ce_count:71768
/sys/devices/system/edac/mc/mc0/csrow1/ch0_ce_count:0
/sys/devices/system/edac/mc/mc1/csrow0/ch0_ce_count:0
/sys/devices/system/edac/mc/mc1/csrow0/ch1_ce_count:0
/sys/devices/system/edac/mc/mc1/csrow0/ch2_ce_count:0
/sys/devices/system/edac/mc/mc1/csrow1/ch0_ce_count:12520
root@server-60:~# dmidecode -t memory |grep 'Locator: DIMM'
	Locator: DIMM02
	Locator: DIMM03
	Locator: DIMM05
	Locator: DIMM06
	Locator: DIMM07
	Locator: DIMM08
	Locator: DIMM10
	Locator: DIMM11
	Locator: DIMM13
	Locator: DIMM14
	Locator: DIMM15
	Locator: DIMM16
```

- 大部分鍵盤的 SysRq 鍵跟 PrtSc（print screen）鍵是同一個，而 SysRq 鍵的使用方式為：Alt + SysRq + 指令鍵，不同的指令鍵有不同的作用，下表是幾個比較常用的指令鍵。

指令鍵	說明
r	將鍵盤解除 raw 模式（unraw）。
e	送出 SIGTERM 訊號至系統上所有的行程，讓所有正在執行中的程式正常關閉。
i	送出 SIGKILL 訊號至系統上所有的行程，強制所有正在執行中的程式立即關閉。
s	同步（sync）所有掛載磁碟的寫入，讓資料實際寫入實體磁碟。
u	以唯讀（read-only）方式重新掛載所有磁碟。
b	立即重新啟動系統（此動作並不會將資料同步寫入至硬碟，也不會讓硬碟卸載）。
n	重設所有高優先順序（real-time）行程的 nice 設定值。
f	呼叫 oom_kill 中止使用大量記憶體的行程。
o	將電腦直接關機。
k	中止目前 virtual console 下的所有程式（Secure Access Key，SAK）。
