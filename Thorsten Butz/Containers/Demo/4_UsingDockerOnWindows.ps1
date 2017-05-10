# Basic information about docker
docker.exe info 
docker.exe info | Select-String -Pattern 'Isolation'
docker version

# Running containers
docker ps

# Existing images? 
docker images 

# App folder structure
[Math]::Round(
  (Get-ChildItem C:\ProgramData\docker -file -Recurse -ea 0| Measure-Object -Property Length -Sum).Sum / 1GB
,3)

docker images --filter "dangling=true"
docker images --filter "label=*"

# Searching the docker hub / docker store
docker search hello-world --limit 5
docker search hello-world --filter "is-official=true"
docker search hello-world:nanoserver
docker search core
docker search microsoft | Select-String -Pattern 'microsoft/' 
docker search microsoft/nanoserver --filter "is-official=true" # No result, not official build
docker search microsoft/powershell 
docker search microsoft/dotnet-samples  
docker search microsoft/dotnet-framework-samples 
docker search microsoft --no-trunc | Set-Clipboard
docker search microsoft/iis

# Downloading images 
docker pull hello-world # Linux!
docker pull microsoft/nanoserver # Windows!
docker pull microsoft/windowsservercore # Windows!
docker pull microsoft/powershell # LINUX!
docker pull microsoft/dotnet-samples  # Linux
docker pull microsoft/dotnet-framework-samples  # Windows!
docker pull microsoft/iis # Windows!

# Private registry
docker pull yourserver:12345/yourimage

Get-ChildItem C:\ProgramData\docker\containers
docker ps --all # -a // Show all containers (active/inactive)

# NOT OPERATING IN ISE 
docker run --interactive --tty microsoft/windowsservercore 
docker run --interactive --tty microsoft/windowsservercore powershell
docker run -i -t  microsoft/nanoserver
docker run -it microsoft/nanoserver powershell
docker run -it microsoft/dotnet-framework-samples  

# Change the entrypoint (to run an interactive shell here)
# NOT OPERATING IN ISE
docker run -it --entrypoint=powershell microsoft/dotnet-framework-samples

# Stop/remove containers
docker stop $(docker ps --quiet)  # -q
docker rm $(docker ps --quiet --all)  # -q -a

# NOT OPERATING IN ISE // --rm: remove container after usage
docker run --interactive --tty --rm microsoft/nanoserver powershell 
docker run --interactive --isolation hyperv --tty microsoft/nanoserver powershell 
docker run --interactive --isolation default --tty microsoft/nanoserver powershell 

# Windows supports 'default', 'process', or 'hyperv'.
docker info | Select-String -Pattern 'Isolation' 
docker info | findstr 'Isolation'
docker run --interactive --isolation process --tty microsoft/nanoserver powershell 


# Playing around 
docker create microsoft/nanoserver 
docker ps --all
docker start $(docker ps --all --last 1 --quiet)
docker ps #  Container starts and exits immediately

# Inspecting the images
docker inspect microsoft/nanoserver | Set-Clipboard
docker inspect microsoft/iis | Set-Clipboard
docker inspect microsoft/nanoserver | Select-String -Pattern 'Exposed' -Context 1
docker inspect microsoft/iis | Select-String -Pattern 'Exposed' -Context 1

# Networking
docker network ls
docker network inspect nat | clip
docker run -it --network  HV_ExternalEthernet microsoft/nanoserver powershell 
docker network create -d transparent --subnet 10.99.0.0/24 --gateway 10.99.0.254 MyLab

# Running a webserver again .. // -d = detached
## NOT Working in W10
docker run -d -p 8888:80 microsoft/iis cmd
docker ps --all