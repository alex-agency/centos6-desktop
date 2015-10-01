alex-centos6-desktop
==========================

Docker Centos 6 Desktop environment

![desktop](https://cloud.githubusercontent.com/assets/1122708/10214427/d4911db2-6820-11e5-9b1b-93f3c59e9866.jpg)

Create dev workstation

```
docker-machine create -d virtualbox dev
```

Get IP address

```
docker-machine ip dev
```

Connect Docker

```
eval "$(docker-machine env dev)"
```

Copy the sources to following path:
MacOS: /Users/<USERNAME>/Docker/centos6-desktop 
Windows: /c/Users/<USERNAME>/Docker/centos6-desktop

Build image

```
docker-machine ssh dev
cd /Users/<USERNAME>/Docker/centos6-desktop
cd /c/Users/<USERNAME>/docker/centos6-desktop
docker build --force-rm=true -t alexagency/centos6-desktop .
```

Run container in the background

```
docker run -d -p 5900:5900 -p 5901:5901 -p 3389:3389 alexagency/centos6-desktop
```

Run container interactive with remove container after exit (--rm)

```
docker run -it --rm -p 5900:5900 -p 5901:5901 -p 3389:3389 alexagency/centos6-desktop
```

VNC & RDP:

```
5900 root:centos, 5901 user:password
```

Show list of all containers:

```
docker ps -a
```

To remove all stopeed containers:

```
docker rm $(docker ps -a -q)
```

Show list of all images:

```
docker images
```

To remove image by id:

```
docker rmi -f <IMAGE ID>
```

To save repository:image to archive:

```
docker save alexagency/centos6-desktop > /Users/<USERNAME>/Desktop/centos6-desktop.tar
```

To load repository from archive:

```
docker load < /Users/<USERNAME>/Desktop/centos6-desktop.tar
```
