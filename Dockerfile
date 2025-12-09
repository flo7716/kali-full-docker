FROM kalilinux/kali-rolling

LABEL maintainer="security-lab"
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

# Base system
RUN apt-get update && apt-get install -y \
    kali-linux-default \
    kali-tools-top10 \
    kali-tools-web \
    kali-tools-wireless \
    kali-tools-exploitation \
    kali-tools-fuzzing \
    kali-tools-forensics \
    kali-tools-passwords \
    kali-tools-crypto-stego \
    kali-tools-sniffing-spoofing \
    kali-tools-database \
    kali-tools-reversing \
    kali-tools-vulnerability \
    curl wget git unzip xz-utils vim tmux zsh less \
    man-db bash-completion apt-transport-https \
    net-tools iputils-ping iputils-tracepath \
    tor proxychains4 \
    locate \
    && apt-get clean

# Install NodeJS (LTS 18)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && npm install -g yarn && \
    apt-get clean

# Oh-my-zsh
RUN apt-get install -y zsh && \
    chsh -s /usr/bin/zsh && \
    git clone https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh && \
    cp /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc

# SecLists
RUN git clone https://github.com/danielmiessler/SecLists /usr/share/seclists

# Code-Server
RUN mkdir -p /opt/code-server && \
    curl -Ls https://api.github.com/repos/coder/code-server/releases/latest \
    | grep "browser_download_url.*linux-amd64" \
    | cut -d ":" -f 2,3 | tr -d \" \
    | xargs curl -Ls \
    | tar xz -C /opt/code-server --strip 1 && \
    ln -s /opt/code-server/code-server /usr/bin/code-server

# Proxychains config (random)
RUN sed -i 's/^strict_chain/#strict_chain/g; s/^#random_chain/random_chain/' /etc/proxychains4.conf

# Tor circuit refresh
RUN echo "MaxCircuitDirtiness 10" >> /etc/tor/torrc

# Update DB
RUN updatedb

CMD ["/bin/zsh"]
