alex-centos6-desktop
==========================

Docker Centos 6 Desktop environment

To build:

Copy the sources down (.) or use local path (/Users/Alex/Docker/centos6-desktop):

```
# docker build --force-rm -t alex/centos6:desktop /Users/Alex/Docker/centos6-desktop
```

To run with remove container after exit (--rm):

```
# docker run -it --rm -p 5900:5900 -p 3389:3389 alex/centos6:desktop
```

VNC password:

```
# password
```

Show list of all containers:

```
# docker ps -a
```

To remove container by id:

```
# docker rm -f <CONTAINER ID>
```

Show list of all images:

```
# docker images
```

To remove image by id:

```
# docker rmi -f <IMAGE ID>
```

