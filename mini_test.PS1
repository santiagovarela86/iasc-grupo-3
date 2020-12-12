Start-Process -FilePath iex.bat -WorkingDirectory .\Router -ArgumentList "--werl --sname Router1@localhost -S mix"    

Start-Sleep -s 10

Start-Process -FilePath iex.bat -WorkingDirectory .\Server -ArgumentList "--werl --sname Server1@localhost -S mix"

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Cliente -ArgumentList "--werl --sname usuario1 -S mix"

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Cliente -ArgumentList "--werl --sname usuario2 -S mix" 