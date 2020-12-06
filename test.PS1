Start-Process -FilePath iex.bat -WorkingDirectory .\Router -ArgumentList "--werl --sname router-1@localhost -S mix"    

Start-Sleep -s 8

Start-Process -FilePath iex.bat -WorkingDirectory .\Server -ArgumentList "--werl --sname server-1 -S mix" 

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Cliente -ArgumentList "--werl --sname usuario1 -S mix" 

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Cliente -ArgumentList "--werl --sname usuario2 -S mix" 

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Cliente -ArgumentList "--werl --sname usuario3 -S mix" 
