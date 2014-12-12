FROM centos:centos6
MAINTAINER Alex

# Install the appropriate software
RUN yum -y update && yum -y groupinstall "Desktop" "X Window System" "Fonts"
RUN yum -y update && yum -y install \
gedit file-roller gnome-system-monitor nautilus-open-terminal firefox \ 
wget nano git samba-client samba-common cifs-utils unzip htop python-setuptools
RUN wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && \
	rpm -Uvh epel-release-6*.rpm; rm -f epel-release-6*.rpm

# Variables
ENV ROOT_PASSWD  centos
ENV USER_PASSWD  password

# VNC & XRDP Servers
RUN yum -y update && yum -y install tigervnc tigervnc-server tigervnc-server-module xrdp xinetd && \
	chkconfig vncserver on 3456 && \
	useradd user && \
	su user sh -c " yes $USER_PASSWD | vncpasswd " && echo "user:$USER_PASSWD" | chpasswd && \
	su root sh -c " yes $ROOT_PASSWD | vncpasswd " && echo "root:$ROOT_PASSWD" | chpasswd && \
	echo -e  "\
VNCSERVERS=\"0:root 1:user\"\n\
VNCSERVERARGS[0]=\"-geometry 1280x800\""\\n\
"VNCSERVERARGS[1]=\"-geometry 1280x800\""\\\
> /etc/sysconfig/vncservers && \
	chkconfig xrdp on 3456 && \
	chmod -v +x /etc/init.d/xrdp && \
	chmod -v +x /etc/xrdp/startwm.sh && \
	echo "gnome-session --session=gnome" > ~/.xsession

# Supervisor
RUN easy_install supervisor && \
	mkdir -p /var/log/supervisor && \
	mkdir -p /etc/supervisord.d && \
	echo -e "\
[supervisord]\n\
nodaemon=true\n\
logfile=/var/log/supervisor/supervisord.log\n\
logfile_maxbytes=50MB\n\
logfile_backups=10\n\
loglevel=info\n\
pidfile=/var/run/supervisord.pid\n\
childlogdir=/var/log\n\n\
[include]\n\
files = /etc/supervisord.d/*.conf"\
> /etc/supervisord.conf

RUN echo -e  "\
[program:vncserver]\n\
command=/etc/init.d/vncserver start && tail -f\n\
autostart=true\n\
autorestart=true\n\
stderr_logfile=/var/log/supervisor/vncserver.err.log\n\
stdout_logfile=/var/log/supervisor/vncserver.out.log"\
> /etc/supervisord.d/vncserver.conf

# Applying Gnome Settings for all users
RUN gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	--type bool  --set /apps/nautilus/preferences/always_use_browser true && \
	gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	--type bool --set /apps/gnome-screensaver/idle_activation_enabled false && \
	gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	--type bool --set /apps/gnome-screensaver/lock_enabled false && \
	gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	--type int --set /apps/metacity/general/num_workspaces 1 && \
	gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	--type=string --set /apps/gnome_settings_daemon/keybindings/screensaver ' ' && \
	gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	--type=string --set /apps/gnome_settings_daemon/keybindings/power ' ' && \
	gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	--type bool --set /apps/panel/global/disable_log_out true && \
	gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	--type int --set /apps/gnome-power-manager/timeout/sleep_computer_ac '0' && \
	gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	--type int --set /apps/gnome-power-manager/timeout/sleep_display_ac '0' && \
	gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	--type int --set /apps/gnome-screensaver/power_management_delay '0'
	gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	--type bool --set /desktop/gnome/remote_access/enabled true
	gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	--type bool --set /desktop/gnome/remote_access/prompt_enabled false

# Cleanup
RUN yum clean all; rm -rf /tmp/* /var/log/*

# Inform which port could be opened
EXPOSE 5900 5901 3389

# Exec configuration to container
ENTRYPOINT \
	/etc/init.d/vncserver start && tail -f #&& \
	#/etc/init.d/xrdp start

# Default argument to container
CMD [ "bash" ]

