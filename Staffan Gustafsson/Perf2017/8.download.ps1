using module ./release/perf
$largerFile = "ftp://ftp.vim.org/pub/vim/pc/gvim80-586.exe"

return # to not run it accedentally on conference with crappy network

Measure-WebDownload -Uri $largerFile -ov res

$res | Out-Chart -Property Kind, TimeMs -Title "Web download" -ChartType Bar

