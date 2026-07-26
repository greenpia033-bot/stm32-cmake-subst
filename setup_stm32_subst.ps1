# ============================================================
# STM32 CMake 项目自动 subst 映射脚本
# 功能：扫描当前文件夹下的 STM32 CMake 项目，自动映射到虚拟盘符
# 用法：PowerShell 中运行 .\setup_stm32_subst.ps1
#       setup   - 创建映射
#       remove  - 删除映射
#       list    - 列出所有映射
# ============================================================
param(
    [ValidateSet("setup", "remove", "list")]
    [string]$Action = "setup"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ---------- 配置 ----------
$BaseDir = $ScriptDir
# 驱动器的首选起始字母（跳过 A: B: C: D:）
$StartDriveChar = 'T'
# 是否仅检测第一层子文件夹的项目根
$ScanDepth = 3
# -------------------------

function Write-Banner {
    Write-Host "`n============================================" -ForegroundColor Cyan
    Write-Host "  STM32 CMake 项目 Subst 映射工具" -ForegroundColor Cyan
    Write-Host "============================================`n" -ForegroundColor Cyan
}

function Get-UsedDriveLetters {
    (Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -match '^[A-Z]$' }).Name
}

function Find-AvailableDriveLetter {
    param([string]$StartChar = 'T')
    
    $used = Get-UsedDriveLetters
    $startCode = [int][char]$StartChar.ToUpper()
    
    for ($code = $startCode; $code -le [int][char]'Z'; $code++) {
        $letter = [char]$code
        if ($letter -notin $used) {
            return "${letter}:"
        }
    }
    return $null
}

function Find-STM32CMakeProjects {
    param([string]$BasePath)
    
    $projects = @()
    $allCMakeFiles = Get-ChildItem -Path $BasePath -Filter "CMakeLists.txt" -Recurse -Depth $ScanDepth -File -ErrorAction SilentlyContinue
    
    foreach ($cmakeFile in $allCMakeFiles) {
        $projectDir = $cmakeFile.DirectoryName
        
        # 判断是否是 STM32 项目：查找 .ioc 文件或 STM32 HAL 驱动特征
        $isSTM32 = $false
        $iocFiles = Get-ChildItem -Path $projectDir -Filter "*.ioc" -File -ErrorAction SilentlyContinue
        $halDrivers = Get-ChildItem -Path $projectDir -Filter "STM32G?xx_HAL_Driver" -Recurse -Depth 3 -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
        
        if ($iocFiles.Count -gt 0 -or $halDrivers) {
            $isSTM32 = $true
        }
        
        if ($isSTM32) {
            # 检查是否已有 subst 映射
            $existingDrive = $null
            $substOutput = & subst 2>$null
            foreach ($line in $substOutput) {
                if ($line -match '^([A-Z]):\\: => (.+)$') {
                    $driveLetter = $Matches[1] + ":"
                    $mappedPath = $Matches[2].Trim()
                    # 规范化路径比较 (处理末尾反斜杠差异)
                    $normProject = (Get-Item $projectDir).FullName.TrimEnd('\')
                    $normMapped = (Get-Item $mappedPath -ErrorAction SilentlyContinue).FullName.TrimEnd('\')
                    if ($normMapped -eq $normProject) {
                        $existingDrive = $driveLetter
                        break
                    }
                }
            }
            
            $projects += [PSCustomObject]@{
                Name          = (Get-Item $projectDir).Name
                FullPath      = $projectDir
                RelativePath  = if ($projectDir.StartsWith($BasePath)) { 
                    $projectDir.Substring($BasePath.Length).TrimStart('\', '/') 
                } else { $projectDir }
                Drive         = $existingDrive
                HasSubst      = ($existingDrive -ne $null)
            }
        }
    }
    
    return $projects
}

function Invoke-SetupMapping {
    Write-Banner
    Write-Host "[*] 扫描目录: $BaseDir" -ForegroundColor Gray
    Write-Host "[*] 正在查找 STM32 CMake 项目...`n" -ForegroundColor Gray
    
    $projects = Find-STM32CMakeProjects -BasePath $BaseDir
    
    if ($projects.Count -eq 0) {
        Write-Host "[!] 未找到任何 STM32 CMake 项目" -ForegroundColor Yellow
        Write-Host "    检测条件：目录下需同时包含 CMakeLists.txt 和 .ioc / HAL 驱动" -ForegroundColor Gray
        return
    }
    
    Write-Host "[*] 找到 $($projects.Count) 个项目:`n" -ForegroundColor Green
    
    $maxNameLen = ($projects | ForEach-Object { $_.Name.Length } | Measure-Object -Maximum).Maximum
    foreach ($proj in $projects) {
        $status = if ($proj.HasSubst) { "[已映射 -> $($proj.Drive)]" } else { "[未映射]" }
        $color = if ($proj.HasSubst) { "Green" } else { "Yellow" }
        $padding = $maxNameLen + 4
        $line = "  {0,-$padding} {1}" -f $proj.Name, $status
        Write-Host $line -ForegroundColor $color
        Write-Host "    路径: $($proj.FullPath)" -ForegroundColor DarkGray
    }
    
    # 为未映射项目分配盘符
    $newMappings = @()
    $usedDrives = Get-UsedDriveLetters
    $nextDrive = $StartDriveChar
    
    foreach ($proj in $projects) {
        if (-not $proj.HasSubst) {
            $drive = Find-AvailableDriveLetter -StartChar $nextDrive
            if (-not $drive) {
                Write-Host "`n[!] 没有可用的驱动器号，跳过: $($proj.Name)" -ForegroundColor Red
                continue
            }
            $nextDrive = [char]([int][char]$drive[0] + 1)
            
            Write-Host "`n[+] 映射 $($proj.Name) -> ${drive}:" -ForegroundColor Cyan
            $result = & subst $drive $proj.FullPath 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "    成功: ${drive}: => $($proj.FullPath)" -ForegroundColor Green
                $newMappings += [PSCustomObject]@{ Drive = $drive; Path = $proj.FullPath; Name = $proj.Name }
            } else {
                Write-Host "    失败: $result" -ForegroundColor Red
            }
        }
    }
    
    # 输出摘要
    Write-Host "`n============================================" -ForegroundColor Cyan
    Write-Host "  当前所有映射状态:" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    $allSubst = & subst 2>$null
    if ($allSubst) {
        $allSubst | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
    } else {
        Write-Host "  (无)" -ForegroundColor Gray
    }
    Write-Host ""
    
    # 提示持久化
    if ($newMappings.Count -gt 0) {
        Write-Host "[!] 注意: subst 映射在重启后会丢失" -ForegroundColor Yellow
        Write-Host "    请将本脚本添加到开机自启，或重新运行: " -ForegroundColor Yellow
        Write-Host "    .\$($MyInvocation.MyCommand.Name) setup" -ForegroundColor White
    }
}

function Invoke-RemoveMapping {
    Write-Banner
    Write-Host "[*] 正在查找当前 subst 映射中属于本项目集的内容...`n" -ForegroundColor Gray
    
    $projects = Find-STM32CMakeProjects -BasePath $BaseDir
    $projectPaths = $projects | ForEach-Object { (Resolve-Path $_.FullPath).Path }
    
    $allSubst = & subst 2>$null
    $removed = 0
    
    foreach ($line in $allSubst) {
        if ($line -match '^([A-Z]):\\: => (.+)$') {
            $drive = $Matches[1] + ":"
            $mappedPath = $Matches[2]
            $resolvedMapped = (Resolve-Path $mappedPath -ErrorAction SilentlyContinue).Path
            
            if ($resolvedMapped -and ($resolvedMapped -in $projectPaths)) {
                Write-Host "[-] 删除映射 ${drive}: => $mappedPath" -ForegroundColor Yellow
                & subst $drive /d 2>$null
                $removed++
            }
        }
    }
    
    if ($removed -eq 0) {
        Write-Host "    没有找到属于本项目的 subst 映射" -ForegroundColor Gray
    } else {
        Write-Host "`n[+] 已删除 $removed 个映射" -ForegroundColor Green
    }
}

function Invoke-ListMapping {
    Write-Banner
    Write-Host "[*] 扫描目录: $BaseDir`n" -ForegroundColor Gray
    
    $projects = Find-STM32CMakeProjects -BasePath $BaseDir
    
    if ($projects.Count -eq 0) {
        Write-Host "    未找到任何 STM32 CMake 项目" -ForegroundColor Yellow
    } else {
        Write-Host "[项目列表]" -ForegroundColor Cyan
        foreach ($proj in $projects) {
            $icon = if ($proj.HasSubst) { "[+]" } else { "[ ]" }
            $color = if ($proj.HasSubst) { "Green" } else { "Gray" }
            Write-Host "  $icon $($proj.Name)" -ForegroundColor $color
            Write-Host "     路径: $($proj.FullPath)" -ForegroundColor DarkGray
            if ($proj.HasSubst) {
                Write-Host "     盘符: $($proj.Drive)" -ForegroundColor Green
            }
        }
    }
    
    Write-Host "`n[当前所有 subst 映射]" -ForegroundColor Cyan
    $allSubst = & subst 2>$null
    if ($allSubst) {
        $allSubst | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
    } else {
        Write-Host "  (无)" -ForegroundColor Gray
    }
    Write-Host ""
}

# ---------- 主入口 ----------
switch ($Action) {
    "setup"  { Invoke-SetupMapping }
    "remove" { Invoke-RemoveMapping }
    "list"   { Invoke-ListMapping }
}
