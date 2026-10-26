@echo off
REM ===========================================================================
REM Register a Windows Task Scheduler job that re-heals quiz-app host ports
REM after the GPU PC resumes from sleep (Docker Desktop / WSL2 drops the
REM host->container port proxy on resume; see docs/operations/remote-gpu.md).
REM
REM Trigger : Microsoft-Windows-Power-Troubleshooter EventID 1 (system resumed)
REM Action  : wsl.exe -> bash -> scripts/resume-heal.sh  (idempotent)
REM Runs    : as the interactive user (/IT), only when logged on -> no stored
REM           password; the session exists (locked) after a WoL resume.
REM
REM Values to adjust for your box (the two "set" lines below):
REM   WSL_DISTRO           WSL distro name (wsl -l -q)
REM   REPO_IN_WSL          repo location inside WSL ("~" = the distro's default user)
REM The task runs as the Windows user who runs this script, and WSL runs as
REM the distro's default user.
REM
REM Run this from a normal (non-elevated) cmd: just double-click or
REM   cmd /c install-resume-task.cmd
REM Remove with:  schtasks /Delete /TN "quizgpu-resume-restart" /F
REM ===========================================================================
set "WSL_DISTRO=Ubuntu"
set "REPO_IN_WSL=~/workspace/quiz-app"
schtasks /Create /TN "quizgpu-resume-restart" /SC ONEVENT /EC System ^
  /MO "*[System[Provider[@Name='Microsoft-Windows-Power-Troubleshooter'] and EventID=1]]" ^
  /TR "wsl.exe -d %WSL_DISTRO% -e bash -lc \"%REPO_IN_WSL%/scripts/resume-heal.sh\"" ^
  /RU %USERNAME% /IT /RL LIMITED /F
