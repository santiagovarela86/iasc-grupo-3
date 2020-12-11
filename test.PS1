Start-Process -FilePath iex.bat -WorkingDirectory .\Router -ArgumentList "--werl --sname Router1@localhost -S mix"    

Start-Sleep -s 4

Start-Process -FilePath iex.bat -WorkingDirectory .\Router -ArgumentList "--werl --sname Router2@localhost -S mix"    

Start-Sleep -s 4

Start-Process -FilePath iex.bat -WorkingDirectory .\Router -ArgumentList "--werl --sname Router3@localhost -S mix"    

Start-Sleep -s 8

Start-Process -FilePath iex.bat -WorkingDirectory .\Server -ArgumentList "--werl --sname Server1@localhost -S mix"

Start-Sleep -s 4

Start-Process -FilePath iex.bat -WorkingDirectory .\Server -ArgumentList "--werl --sname Server2@localhost -S mix"

Start-Sleep -s 4

Start-Process -FilePath iex.bat -WorkingDirectory .\Server -ArgumentList "--werl --sname Server3@localhost -S mix"

Start-Sleep -s 4

Start-Process -FilePath iex.bat -WorkingDirectory .\Server -ArgumentList "--werl --sname Server4@localhost -S mix"

Start-Sleep -s 4

Start-Process -FilePath iex.bat -WorkingDirectory .\Cliente -ArgumentList "--werl --sname usuario1 -S mix" 

Start-Sleep -s 4

Start-Process -FilePath iex.bat -WorkingDirectory .\Cliente -ArgumentList "--werl --sname usuario2 -S mix" 

Start-Sleep -s 4

Start-Process -FilePath iex.bat -WorkingDirectory .\Cliente -ArgumentList "--werl --sname usuario3 -S mix" 
