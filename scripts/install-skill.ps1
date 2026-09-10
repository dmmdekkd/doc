<#
.SYNOPSIS
  jumpbyte-bot Skill 一键安装脚本（Windows / PowerShell）

.DESCRIPTION
  将 jumpbyte-bot 的 SKILL.md（项目 AI 知识包）安装到各 IDE / AI Agent 的
  skills 目录，让 AI 打开项目即可理解架构、协议、算法与文档维护方式。

  支持两种运行模式：
    [本地模式] 已克隆仓库（PowerShell 7+ 或 Windows PowerShell 5.1）：
      .\scripts\install-skill.ps1 -All

    [远程一键模式] 无需克隆仓库：
      irm https://raw.githubusercontent.com/dmmdekkd/doc/main/scripts/install-skill.ps1 | iex
      带参数：
      iex "& { $(irm https://raw.githubusercontent.com/dmmdekkd/doc/main/scripts/install-skill.ps1) } -All"

  支持目标：trae, cursor, claude, cline, continue, github-copilot

.PARAMETER All
  安装到全部支持的目标（远程一键模式默认即为全装）
.PARAMETER Ide
  指定目标，逗号分隔，如 -Ide "trae,cursor"
.PARAMETER List
  列出支持的目标与安装位置
.PARAMETER Force
  强制覆盖已存在且不同的副本

.EXAMPLE
  irm https://raw.githubusercontent.com/dmmdekkd/doc/main/scripts/install-skill.ps1 | iex
.EXAMPLE
  iex "& { $(irm https://raw.githubusercontent.com/dmmdekkd/doc/main/scripts/install-skill.ps1) } -Ide trae,cursor"
#>
[CmdletBinding()]
param(
  [switch]$All,
  [string]$Ide = "",
  [switch]$List,
  [switch]$Force
)

$ErrorActionPreference = "Stop"

# PS 5.1 兼容：强制 TLS 1.2（GitHub 需要）
try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 } catch {}

$SkillName = "jumpbyte-bot"
$Repo = "dmmdekkd/doc"
$Branch = "main"
$RawUrl = if ($env:SKILL_RAW_URL) {
  $env:SKILL_RAW_URL
} else {
  "https://raw.githubusercontent.com/$Repo/$Branch/.trae/skills/$SkillName/SKILL.md"
}

$Order = @("trae", "cursor", "claude", "cline", "continue", "github-copilot")

# ---------------------------------------------------------------------------
# 0. 定位权威源：优先本地仓库，否则远程下载（远程一键模式）
# ---------------------------------------------------------------------------
$LocalRoot = $null
if ($PSScriptRoot) {
  $cand = Split-Path -Parent $PSScriptRoot
  if (Test-Path (Join-Path $cand ".trae\skills\$SkillName\SKILL.md")) { $LocalRoot = $cand }
}
if (-not $LocalRoot -and (Test-Path ".\.trae\skills\$SkillName\SKILL.md")) { $LocalRoot = (Get-Location).Path }

$SkillContent = $null
$SrcPath = $null
if ($LocalRoot) {
  $SrcPath = Join-Path $LocalRoot ".trae\skills\$SkillName\SKILL.md"
  Write-Host "[info] 本地模式：使用仓库权威源 $SrcPath"
  $SkillContent = Get-Content -Raw -LiteralPath $SrcPath
} else {
  Write-Host "[info] 远程模式：下载 SKILL.md <- $RawUrl"
  try {
    $resp = Invoke-WebRequest -UseBasicParsing -Uri $RawUrl -TimeoutSec 30
  } catch {
    Write-Host "[error] 远程下载失败: $RawUrl"
    Write-Host "        可设置环境变量 SKILL_RAW_URL 指定镜像/加速地址后重试。"
    exit 1
  }
  $SkillContent = $resp.Content
}

# ---------------------------------------------------------------------------
# 1. 目标目录：本地模式用仓库相对目录，远程模式用 %USERPROFILE% 全局目录
# ---------------------------------------------------------------------------
function Get-Dest([string]$key) {
  if ($LocalRoot) {
    $base = switch ($key) {
      "trae"           { Join-Path $LocalRoot ".trae" }
      "cursor"         { Join-Path $LocalRoot ".cursor" }
      "claude"         { Join-Path $LocalRoot ".claude" }
      "cline"          { Join-Path $LocalRoot ".cline" }
      "continue"       { Join-Path $LocalRoot ".continue" }
      "github-copilot" { Join-Path $LocalRoot ".github" }
    }
  } else {
    $userHome = $env:USERPROFILE
    $base = switch ($key) {
      "trae"           { Join-Path $userHome ".trae" }
      "cursor"         { Join-Path $userHome ".cursor" }
      "claude"         { Join-Path $userHome ".claude" }
      "cline"          { Join-Path $userHome ".cline" }
      "continue"       { Join-Path $userHome ".continue" }
      "github-copilot" { Join-Path $userHome ".github" }
    }
  }
  Join-Path $base "skills\$SkillName"
}

if ($List) {
  Write-Host "支持的目标："
  foreach ($k in $Order) {
    Write-Host ("  {0,-18} -> {1}" -f $k, (Get-Dest $k))
  }
  Write-Host "权威源: $SrcPath"
  exit 0
}

# ---------------------------------------------------------------------------
# 2. 组装要安装的目标列表
# ---------------------------------------------------------------------------
$selected = @()
if ($All) {
  $selected = $Order
} elseif ($Ide) {
  foreach ($k in ($Ide -split "," | ForEach-Object { $_.Trim() })) {
    if ($k -and $Order -contains $k) { $selected += $k }
    else { Write-Warning "未知目标: $k" }
  }
} else {
  # auto：本地模式探测已存在的 skills 目录（无则默认 trae）；远程模式全装到用户全局
  if ($LocalRoot) {
    foreach ($k in $Order) {
      if (Test-Path (Get-Dest $k)) { $selected += $k }
    }
    if ($selected.Count -eq 0) { $selected = @("trae") }
  } else {
    $selected = $Order
  }
}
$selected = @($selected | Select-Object -Unique)

if ($selected.Count -eq 0) {
  Write-Error "未选择任何目标，使用 -All 或 -Ide xxx"
  exit 1
}

# ---------------------------------------------------------------------------
# 3. 执行安装（UTF-8 无 BOM 写入，兼容所有解析器）
# ---------------------------------------------------------------------------
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$installed = 0
foreach ($k in $selected) {
  $dst = Get-Dest $k
  $dstFile = Join-Path $dst "SKILL.md"

  # 目标与权威源相同（本地模式下 trae 目录即权威源）→ 跳过
  if ($LocalRoot -and $dstFile -eq $SrcPath) {
    Write-Host "[ok]   $k 权威源已就位（$dstFile），无需复制"
    $installed++
    continue
  }

  New-Item -ItemType Directory -Force -Path $dst | Out-Null
  if ((Test-Path $dstFile) -and -not $Force) {
    $old = Get-Content -Raw -LiteralPath $dstFile
    if ($old -ne $SkillContent) {
      Write-Host "[skip] $k 已存在且与源不同，使用 -Force 覆盖: $dstFile"
      continue
    }
  }
  [System.IO.File]::WriteAllText($dstFile, $SkillContent, $utf8NoBom)
  Write-Host "[ok]   $k <- $dstFile"
  $installed++
}

Write-Host "完成，共安装 $installed 个目标。"
if ($LocalRoot) {
  Write-Host "提示：修改权威源 .trae\skills\$SkillName\SKILL.md 后，重新运行本脚本即可同步到各 IDE。"
} else {
  Write-Host "提示：远程模式下已安装到用户全局目录，对所有项目生效。更新：重跑同一条远程命令即可。"
}