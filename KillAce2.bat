@echo off
chcp 65001 >nul
title 强制终止 SGuardSvc64 与 SGuard64 (SYSTEM 权限)

:: 1. 检查当前是否为 SYSTEM 权限
whoami | findstr /i "system" >nul 2>&1
if %errorlevel% equ 0 goto :RUN_AS_SYSTEM

:: 2. 检查管理员权限并提权
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [提示] 正在请求管理员权限...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: 3. 通过 PsExec 提升至 SYSTEM 权限
echo [提示] 正在提升至 SYSTEM 权限...
psexec -i -s "%~f0"
exit /b

:RUN_AS_SYSTEM
echo ====================================================
echo 当前运行权限: NT AUTHORITY\SYSTEM
echo ====================================================
echo.

set S1=SGuardSvc64.exe
set S2=SGuard64.exe

echo [1/3] 正在执行单指令“联合强杀” (先斩首守护进程 SGuardSvc64)...
echo ----------------------------------------------------
:: 单条命令同时传入多个 /IM 参数，并在第一个参数加上 /T (树状终止)
:: 先杀 SGuardSvc64 切断复活逻辑，紧接着杀 SGuard64
taskkill /F /IM "%S1%" /IM "%S2%" /T 2>NUL
taskkill /F /IM SGuardSvc64 /IM SGuard64 /T 2>NUL

echo ----------------------------------------------------
echo.
echo [2/3] 正在等待 1 秒并验证进程状态...
timeout /t 1 /nobreak >nul

:: 检查是否还有残留
set REMAINING=0
tasklist /FI "IMAGENAME eq %S1%" 2>NUL | find /I "%S1%" >nul && set REMAINING=1
tasklist /FI "IMAGENAME eq %S2%" 2>NUL | find /I "%S2%" >nul && set REMAINING=1

if %REMAINING% equ 1 (
    echo [警告] 极短时间内发生抢跑，正在执行二次补充清理...
    taskkill /F /IM "%S1%" /T 2>NUL
    taskkill /F /IM "%S2%" /T 2>NUL
)

echo.
echo [3/3] 清理结果核验:
echo ----------------------------------------------------
tasklist /FI "IMAGENAME eq %S1%" 2>NUL | find /I "%S1%" >nul
if %errorlevel% equ 0 (
    echo  - %S1%: 仍然存活 (清理失败)
) else (
    echo  - %S1%: 已彻底终止
)

tasklist /FI "IMAGENAME eq %S2%" 2>NUL | find /I "%S2%" >nul
if %errorlevel% equ 0 (
    echo  - %S2%: 仍然存活 (清理失败)
) else (
    echo  - %S2%: 已彻底终止
)
echo ----------------------------------------------------

echo.
echo 按任意键退出...
pause >nul