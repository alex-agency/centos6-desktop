FROM centos:centos6
MAINTAINER Alex

# Install the appropriate software
RUN yum -y update && yum -y groupinstall "Desktop" "X Window System" "Fonts"
RUN yum -y install epel-release wget gedit file-roller gnome-system-monitor nautilus-open-terminal \
		samba-client samba-common unzip firefox git nano htop python-setuptools && \
	yum clean all && rm -rf /tmp/*

# Variables
ENV ROOT_PASSWD  centos
ENV USER_PASSWD  password

# VNC & XRDP Servers
RUN yum -y update && \
	yum -y install tigervnc tigervnc-server tigervnc-server-module xrdp xinetd && \
	yum clean all && rm -rf /tmp/* && \
	chkconfig vncserver on 3456 && \
	echo -e  "\
VNCSERVERS=\"0:root 1:user\"\n\
VNCSERVERARGS[0]=\"-geometry 1280x960\"\n\
VNCSERVERARGS[1]=\"-geometry 1280x960\""\
>> /etc/sysconfig/vncservers && \
	chkconfig xrdp on 3456 && \
	chmod -v +x /etc/init.d/xrdp && \
	chmod -v +x /etc/xrdp/startwm.sh && \
	echo "gnome-session --session=gnome" > ~/.xsession

# Create User and change passwords
RUN su root sh -c "yes $ROOT_PASSWD | vncpasswd" && echo "root:$ROOT_PASSWD" | chpasswd && \
	useradd user && \
	su user sh -c "yes $USER_PASSWD | vncpasswd" && echo "user:$USER_PASSWD" | chpasswd

# Supervisor
RUN easy_install supervisor && \
	mkdir -p /var/log/supervisor && \
	mkdir -p /etc/supervisord.d && \
	echo -e "\
[supervisord]\n\
nodaemon=true\n\
logfile=/var/log/supervisor/supervisord.log\n\
logfile_maxbytes=1MB\n\
logfile_backups=1\n\
loglevel=warn\n\
pidfile=/var/run/supervisord.pid\n\
[include]\n\
files = /etc/supervisord.d/*.conf"\
> /etc/supervisord.conf
# Autostart services
RUN echo -e  "\
[program:xrdp]\n\
command=/etc/init.d/xrdp restart\n\
stderr_logfile=/var/log/supervisor/xrdp-error.log\n\
stdout_logfile=/var/log/supervisor/xrdp.log"\
> /etc/supervisord.d/xrdp.conf && \
	echo -e  "\
[program:vncserver]\n\
command=/etc/init.d/vncserver restart\n\
stderr_logfile=/var/log/supervisor/vncserver-error.log\n\
stdout_logfile=/var/log/supervisor/vncserver.log"\
> /etc/supervisord.d/vnc.conf

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
	--type int --set /apps/gnome-screensaver/power_management_delay '0' && \
	gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	--type bool --set /desktop/gnome/remote_access/enabled true && \
	gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
	--type bool --set /desktop/gnome/remote_access/prompt_enabled false

# Inform which port could be opened
EXPOSE 5900 5901 3389

# Exec configuration to container
CMD ["supervisord"]
