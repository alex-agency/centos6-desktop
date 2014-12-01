FROM centos:centos6
MAINTAINER Alex

RUN yum clean all; yum -y update

# Install the appropriate software
RUN yum -y groupinstall "Desktop" "Desktop Platform" "X Window System" "Fonts"
RUN yum -y install wget nano gedit firefox nautilus-open-terminal

# Java 8
RUN wget -c --no-cookies  --no-check-certificate  --header "Cookie: oraclelicense=accept-securebackup-cookie" \
	"http://download.oracle.com/otn-pub/java/jdk/8-b132/jdk-8-linux-x64.rpm"  -O /tmp/jdk-8-linux-x64.rpm  && \
	rpm -i /tmp/jdk-8-linux-x64.rpm && rm -fv /tmp/jdk-8-linux-x64.rpm && \
	echo "export JAVA_HOME=/usr/java/jdk1.8.0" >> /etc/bashrc && \
	echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/bashrc && \
	alternatives   --install /usr/bin/java java /usr/java/jdk1.8.0/bin/java 1 && \
	alternatives   --set  java  /usr/java/jdk1.8.0/bin/java && \
	java -version
ENV JAVA_HOME /usr/java/jdk1.8.0 && \
	JRE_HOME /usr/java/jdk1.8.0/jre
# Firefox Java plugin
RUN cd /usr/lib64/mozilla/plugins/ && \
	ln -fs /usr/java/latest/lib/amd64/libnpjp2.so

# VNC & XRDP Servers
RUN wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && \
	rpm -Uvh epel-release-6*.rpm; rm -f epel-release-6*.rpm
RUN yum -y install tigervnc tigervnc-server tigervnc-server-module xrdp xinetd
RUN chkconfig vncserver on 3456 && \
	su root sh -c " yes password | vncpasswd " && \
	echo -e  "VNCSERVERS=\"0:root\"\nVNCSERVERARGS[0]=\"-geometry 1280x800 \""\
	> /etc/sysconfig/vncservers && \
	chkconfig xrdp on 3456 && \
	chmod -v +x /etc/init.d/xrdp && \
	mv /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.backup && \
echo -e "#!/bin/sh\n\nif [ -r /etc/default/locale ]; then\n  . /etc/default/locale\n\
export LANG LANGUAGE\nfi\n. /etc/X11/xinit/Xsession\ngnome-session --session=gnome"\
>> /etc/xrdp/startwm.sh && \
	chmod -v +x /etc/xrdp/startwm.sh && \
	echo "gnome-session --session=gnome" > ~/.xsession

# Sublime Text 3
RUN	wget http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3065_x64.tar.bz2 && \
	tar -vxjf sublime_text_3_build_3065_x64.tar.bz2 -C /opt && \
	ln -s /opt/sublime_text_3/sublime_text /usr/bin/sublime3 && \
	rm -f sublime_text_3_build_3065_x64.tar.bz2 && \
echo -e "[Desktop Entry]\nName=Sublime 3\nExec=sublime3\nTerminal=false\n\
Icon=/opt/sublime_text_3/Icon/48x48/sublime-text.png\nType=Application\n\
Categories=TextEditor;IDE;Development\nX-Ayatana-Desktop-Shortcuts=NewWindow\n\n\
[NewWindow Shortcut Group]\nName=New Window\nExec=sublime -n\nTargetEnvironment=Unity"\
>> /usr/share/applications/sublime3.desktop
CMD touch /root/.config/sublime-text-3 && \
	chown -R root:root /root/.config/sublime-text-3

# Chrome
RUN	wget http://chrome.richardlloyd.org.uk/install_chrome.sh && \
	chmod -v u+x install_chrome.sh; ./install_chrome.sh -f && \
	rm -f install_chrome.sh; rm -rf /root/rpmbuild

# Eclipse Luna
RUN	wget http://mirrors.nic.cz/eclipse/technology/epp/downloads/release/luna/SR1/\
eclipse-java-luna-SR1-linux-gtk-x86_64.tar.gz && \
	tar -zxvf eclipse-java-luna-SR1-linux-gtk-x86_64.tar.gz -C /usr/ && \
	ln -s /usr/eclipse/eclipse /usr/bin/eclipse && \
	rm -f eclipse-java-luna-SR1-linux-gtk-x86_64.tar.gz && \
echo -e "[Desktop Entry]\nEncoding=UTF-8\nName=Eclipse 4.4.1\nComment=Eclipse Luna\n\
Exec=/usr/bin/eclipse\nIcon=/usr/eclipse/icon.xpm\nCategories=Application;Development;Java;IDE\n\
Version=1.0\nType=Application\nTerminal=0"\
>> /usr/share/applications/eclipse-4.4.desktop

# Clean
RUN yum clean all; rm -rf /tmp/*

# Applying Settings
RUN gconftool-2 --type bool  --set /apps/nautilus/preferences/always_use_browser true

EXPOSE 5900 3389

CMD    vncserver :0 && /etc/init.d/xrdp start && bash
