FROM kalilinux/kali-rolling:latest

LABEL description="Kali Docker Container with Tools and VNC enabled"

ARG KALI_DESKTOP=xfce
ENV USER root
ENV VNCEXPOSE 0
ENV VNCPORT 5900
ENV VNCPWD changeme
ENV VNCDISPLAY 1920x1080
ENV VNCDEPTH 16
ENV SSHKEY 0
ENV NOVNCPORT 8080

# Install kali packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install kali-linux-default kali-tools-wireless kali-tools-web kali-tools-vulnerability kali-tools-802.11 kali-tools-windows-resources kali-linux-core

# Install kali desktop
RUN apt-get -y install kali-desktop-${KALI_DESKTOP}
RUN apt-get -y install tightvncserver dbus dbus-x11 novnc net-tools

# Add Tools
RUN apt-get -y install nano make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev jython catfish eyewitness golang lftp nuclei openjdk-11-jre-headless openjdk-11-jre proxychains seclists testssl.sh xpdf xxd nikto responder mitmproxy impacket-scripts nuclei

# Clean apt
RUN apt-get clean

# Postman
RUN mkdir -p /opt/tools/
RUN cd /opt/tools && wget https://dl.pstmn.io/download/version/9.31.28/linux -O Postman.tar.gz
RUN cd /opt/tools && tar -xvzf Postman.tar.gz
RUN cd /opt/tools && rm -f Postman.tar.gz

# Burp
RUN wget "https://portswigger-cdn.net/burp/releases/download?product=pro&type=Linux" -O /opt/tools/burp-install.sh
RUN chmod +x /opt/tools/burp-install.sh
RUN /opt/tools/burp-install.sh -q
RUN wget "https://repo1.maven.org/maven2/org/python/jython-standalone/2.7.3/jython-standalone-2.7.3.jar" -O /opt/tools/jython.jar
RUN rm /opt/tools/burp-install.sh

# Setup GOLANG
RUN go install -v github.com/shenwei356/rush@latest
RUN go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest

# Setup PYENV and SSH
RUN curl https://pyenv.run | bash
RUN echo "# pyenv" >> ~/.bashrc
RUN echo export PYENV_ROOT=\"\$HOME/.pyenv\" >> ~/.bashrc
RUN echo command -v pyenv \>/dev/null \|\| export PATH=\"\$PYENV_ROOT/bin:\$\PATH\" >> ~/.bashrc
RUN echo eval \"\$\(pyenv init -\)\" >> ~/.bashrc
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN echo "X11UseLocalhost no" >> /etc/ssh/sshd_config

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
