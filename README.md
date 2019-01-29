# webDocker
## Setp server
### setup.sh
```
wget https://raw.githubusercontent.com/app2linux/webDebian/master/setup.sh
chmod +x ./setup.sh
./setup.sh
```
## Sever maintenance options
### setup.sh
```
./setup.sh
```
### start.sh
```
cd .startup
./start.sh
cd ..
```
## Server files maintenance
```
cd .startup
./<filename>.sh <options>
cd ..
```
### setupServer.sh
Update server & install
```
./setupServer.sh
```
### startup.sh
```
./startup.sh [<nameMainDomain>.<extension>] [<subdomain> <subdomain>] [NOIP] [ERRORLOCAL]
```
### context.sh
```
./context.sh
```
### nginxConfig.sh
```
./nginxConfig.sh
```
### syncDav.sh
```
./syncDav.sh dav=<davServer> user=<davUser> pw=<davPw>
```
### nginxStart.sh
Start docker nginx server
```
./nginxStart.sh [start] [stop] [restart] [reimage] [console] [logs] [stat]
```
