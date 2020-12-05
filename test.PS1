$env:type = 'router'
iex.bat --werl --sname router-1@localhost -S mix

$env:type = 'server'
iex.bat --werl --sname server-1 -S mix

Start-Sleep -s 5

$env:type = 'client'
iex.bat --sname usuario1 --werl -S mix

$env:type = 'client'
iex.bat --sname usuario2 --werl -S mix

$env:type = 'client'
iex.bat --sname usuario3 --werl -S mix