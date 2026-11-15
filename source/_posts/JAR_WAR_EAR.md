---
title: JAR_WAR_EAR
date: 2016-06-20 14:12:52
tags:
- jar
- war
- ear
- java
---

##### 本篇探討 EAR、JAR、WAR 之間的異同，主要目的都是將 Java 封裝成檔案，便於存放管理，事實上三者皆採用 zip 或 jar 檔案文件壓縮，但使用目地有其差異：
<!-- more -->
### JAR
全寫為 Java Archive ，包括 JavaBeans 、Java Classes、資源 (Resources)、輔助文件 (auxilary files)、Property 等，目的是為了產了 Java Library 用，且可以將好幾個 java 內容成單一檔案，是文件封裝的最小單位。

部署文件：application-client.xml

### WAR
全寫為 Web Archive，包括全部的 Web 內容，像是 Servlet class files、JSP、GIF、HTML、tag、library、xml 等等，目的是為了包括全部的 Web Application

部署文件：web.xml

### EAR
全寫為 Enterprise Archive ，包括以上全部的應用程序 (.jar) 及 (.war)，封裝成 .ear 檔之後，可 deploy 到 application server

部署文件：application.xml

每一種文件（.jar, .war, .ear）只能由應用服務器（application servers）、小型服務程序容器（servlet containers）、EJB容器（EJB containers）等進行處理。
