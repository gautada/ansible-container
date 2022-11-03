ARG ALPINE_VERSION=3.16.2
# ╭――――――――――――――――---------------------------------------------------------――╮
# │                                                                           │
# │ STAGE 1: configure-ansible -- Pull and configure the ansible environment  │
# │                                                                           │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM gautada/alpine:$ALPINE_VERSION as configure-ansible

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL version="2022-11-02"
LABEL source="https://github.com/gautada/ansible-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="Container that provides an ansible cli environment."

# ╭――――――――――――――――――――╮
# │ ENVIRONMENT        │
# ╰――――――――――――――――――――╯
RUN /bin/mkdir /etc/ansible \
 && /bin/ln -s /opt/ansible/hosts /etc/ansible/hosts \
 && /bin/ln -s /opt/ansible/private.key /etc/ansible/private.key
 
# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
COPY 10-ep-container.sh /etc/container/entrypoint.d/10-ep-container.sh

# ╭――――――――――――――――――――╮
# │ PACKAGES           │
# ╰――――――――――――――――――――╯
RUN /sbin/apk add --no-cache ansible build-base git npm openssh-client openssh yarn
# Dropped: nodejs python3 py3-pip yarn

# ╭――――――――――――――――――――╮
# │ CONFIGURE          │
# ╰――――――――――――――――――――╯
RUN cd /etc/ansible \
 && /usr/bin/git clone https://github.com/gautada/ansible-container.git repo \
 && /bin/ln -s /etc/ansible/repo/playbooks /etc/ansible/playbooks

# mkdir .ssh ; mv public.key ~/.ssh/authorized_keys ; chmod 700 ~/.ssh ;  chmod 640 ~/.ssh/authorized_keys
# ╭――――――――――――――――――――╮
# │ SUDO               │
# ╰――――――――――――――――――――╯
COPY wheel-sshd /etc/container/wheel.d/wheel-sshd
COPY wheel-ssh-keygen /etc/container/wheel.d/wheel-ssh-keygen
COPY wheel-git /etc/container/wheel.d/wheel-git

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG USER=ansible
# VOLUME /opt/$USER
RUN /bin/mkdir -p /opt/$USER \
 && /usr/sbin/addgroup $USER \
 && /usr/sbin/adduser -D -s /bin/ash -G $USER $USER \
 && /usr/sbin/usermod -aG wheel $USER \
 && /bin/echo "$USER:$USER" | chpasswd
# && /bin/chown $USER:$USER -R /opt/$USER
USER $USER
WORKDIR /home/$USER

# ╭――――――――――――――――――――╮
# │ PORTS              │
# ╰――――――――――――――――――――╯
EXPOSE 8080

# ╭――――――――――――――――――――╮
# │ CONFIGURE          │
# ╰――――――――――――――――――――╯
RUN /usr/bin/yarn global add wetty 
