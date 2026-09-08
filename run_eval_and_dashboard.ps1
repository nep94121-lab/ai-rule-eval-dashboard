<#
.SYNOPSIS
    Tự động hóa chạy đánh giá Promptfoo và mở Dashboard xem kết quả.
.DESCRIPTION
    Script thực thi promptfoo eval theo cấu hình chỉ định và khởi chạy giao diện dashboard trực quan.
.PARAMETER Config
    Đường dẫn tệp cấu hình promptfoo (mặc định: promptfooconfig.yaml)
.PARAMETER Port
    Cổng máy chủ dashboard (mặc định: 15500)
.PARAMETER NoView
    Chỉ chạy eval, không tự động mở dashboard
.EXAMPLE
    .\run_eval_and_dashboard.ps1
.EXAMPLE
    .\run_eval_and_dashboard.ps1 -Port 8080 -NoView
#>

[CmdletBinding()]
param(
    [string]$Config = "promptfooconfig.yaml",
    [int]$Port = 15500,
    [switch]$NoView = $false
)

$ErrorActionPreference = "Stop"
$env:PROMPTFOO_DISABLE_UPDATE = "true"
$env:PROMPTFOO_DISABLE_TELEMETRY = "true"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [RULE EVAL SYSTEM] PROMPTFOO EVALUATION & DASHBOARD RUNNER" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Kiểm tra npm/npx
try {
    $npxVersion = & npx promptfoo --version 2>&1
    Write-Host "[INFO] Promptfoo version: $npxVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Không tìm thấy promptfoo. Vui lòng chạy 'npm install' trước." -ForegroundColor Red
    exit 1
}

# Kiểm tra file cấu hình
if (Test-Path -Path $Config) {
    Write-Host "[INFO] Sử dụng file cấu hình: $Config" -ForegroundColor Green
    $evalCmd = "npx promptfoo eval -c $Config"
} else {
    Write-Host "[WARN] Không tìm thấy '$Config'. Chạy mặc định hoặc cần tạo cấu hình." -ForegroundColor Yellow
    $evalCmd = "npx promptfoo eval"
}

# Thực thi eval
Write-Host "[STEP 1/2] Đang thực thi đánh giá rules qua Promptfoo..." -ForegroundColor Yellow
$evalStartTime = Get-Date

try {
    Invoke-Expression $evalCmd
    $evalDuration = (Get-Date) - $evalStartTime
    Write-Host "[SUCCESS] Hoàn thành đánh giá trong $($evalDuration.TotalSeconds.ToString('F2')) giây." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Quá trình eval gặp sự cố: $_" -ForegroundColor Red
    exit 1
}

# Khởi chạy Dashboard nếu không đặt cờ NoView
if (-not $NoView) {
    Write-Host "[STEP 2/2] Khởi chạy Promptfoo Dashboard tại http://localhost:$Port..." -ForegroundColor Yellow
    Write-Host "[INFO] Nhấn Ctrl+C để dừng máy chủ dashboard khi hoàn tất." -ForegroundColor Gray
    npx promptfoo view -p $Port -y
} else {
    Write-Host "[INFO] Bỏ qua khởi chạy dashboard (cờ -NoView đã bật)." -ForegroundColor Green
}
