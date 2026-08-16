# killAce
杀死腾讯的ace进程

前置条件
1.到微软官网下载提权文件
https://learn.microsoft.com/zh-cn/sysinternals/downloads/psexec

2.解压到本地文件

3.打开高级系统设置添加环境变量，选择下方的系统变量新建变量名%SYSTEMTOOLS%,变量值为PsExec64.exe所在的目录。新建好后双击系统变量中的Path变量，新建输入%SYSTEMTOOLS%。一路点击确定即可

**使用方法：
**在每局游戏对局开始后，双击bat文件并给于权限即可

原理
先杀死SGuardSvc64进程，因为它存活会不断拉起SGuard64进程。
