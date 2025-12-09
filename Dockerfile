FROM kalilinux/kali-rolling:latest

LABEL maintainer="info@xaviertorello.cat"
LABEL author="Xavi Torelló"

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

# Base install
RUN apt-get update -y && \
    apt-get install -y \
        software-properties-common \
        kali-linux-headless \
        curl \
        wget \
        ca-certificates && \
    echo 'VERSION_CODENAME=kali-rolling' >> /etc/os-release

# Add NodeJS repo
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

# Install system tools
RUN apt-get install -y \
    git colordiff colortail unzip vim tmux xterm zsh curl telnet \
    strace ltrace tmate less build-essential \
    python3 python3-venv python3-setuptools python3-pip \
    tor proxychains proxychains4 zstd net-tools bash-completion \
    iputils-tracepath nodejs npm yarnpkg \
    virtualenvwrapper \
    locate

# Oh-my-git
RUN git clone https://github.com/arialdomartini/oh-my-git.git /root/.oh-my-git && \
    echo "source /root/.oh-my-git/prompt.sh" >> /etc/profile

# SecLists
RUN git clone https://github.com/danielmiessler/SecLists /usr/share/seclists

# w3af (ATTENTION: sans pip → installation partielle)
RUN apt-get install -y \
        libssl-dev libxml2-dev libxslt1-dev zlib1g-dev \
        python3-pybloomfiltermmap && \
    git clone https://github.com/andresriancho/w3af.git /opt/w3af && \
    echo 'export PATH=/opt/w3af:$PATH' >> /etc/profile

# ngrok
RUN curl -s https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip \
    | gunzip - > /usr/bin/ngrok && chmod +x /usr/bin/ngrok

# code-server
RUN mkdir -p /opt/code-server && \
    curl -Ls https://api.github.com/repos/coder/code-server/releases/latest \
    | grep "browser_download_url.*linux-amd64" \
    | cut -d ":" -f 2,3 | tr -d \" \
    | xargs curl -Ls \
    | tar xz -C /opt/code-server --strip 1 && \
    echo "export PATH=/opt/code-server:$PATH" >> /etc/profile

# virtualenvwrapper config (sans pip)
RUN echo 'export WORKON_HOME=$HOME/.virtualenvs' >> /etc/profile && \
    echo 'export PROJECT_HOME=$HOME/projects' >> /etc/profile && \
    mkdir -p /root/projects && \
    echo 'source /usr/share/virtualenvwrapper/virtualenvwrapper.sh' >> /etc/profile

# Tor refresh every 5 requests
RUN echo "MaxCircuitDirtiness 10" >> /etc/tor/torrc && \
    update-rc.d tor enable

# Proxychains config
RUN sed -i 's/^strict_chain/#strict_chain/g; s/^#random_chain/random_chain/g' /etc/proxychains.conf && \
    sed -i 's/^strict_chain/#strict_chain/g; s/^round_robin_chain/round_robin_chain/g' /etc/proxychains4.conf

# Update DB + clean
RUN updatedb && apt-get autoremove -y && apt-get clean

# Welcome message
RUN echo "echo \"Kali full container!  
- If you need proxychains over Tor, start Tor with:  
    service tor start  
\"" >> /etc/profile

CMD ["/bin/bash", "--init-file", "/etc/profile"]
# End of Dockerfile