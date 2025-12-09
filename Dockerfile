FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

RUN apt-get update && apt-get install -y \
    kali-linux-default \
    kali-tools-top10 \
    kali-tools-passwords \
    kali-tools-wireless \
    curl wget git unzip xz-utils vim tmux zsh less \
    man-db bash-completion apt-transport-https \
    net-tools iputils-ping iputils-tracepath \
    tor proxychains4 \
    locate \
    && apt-get clean

# Oh-my-zsh
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh && \
    cp /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc && \
    chsh -s /usr/bin/zsh

# SecLists
RUN git clone https://github.com/danielmiessler/SecLists /usr/share/seclists

# NodeJS LTS 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && npm install -g yarn && apt-get clean

# Code-Server (VSCode Web)
RUN mkdir -p /opt/code-server && \
    curl -Ls https://api.github.com/repos/coder/code-server/releases/latest \
    | grep "browser_download_url.*linux-amd64" \
    | cut -d ":" -f 2,3 | tr -d \" \
    | xargs curl -Ls \
    | tar xz -C /opt/code-server --strip 1 && \
    ln -s /opt/code-server/bin/code-server /usr/bin/code-server

# Proxychains config
RUN sed -i 's/^strict_chain/#strict_chain/; s/^#random_chain/random_chain/' /etc/proxychains4.conf

# Tor
RUN echo "MaxCircuitDirtiness 10" >> /etc/tor/torrc

RUN updatedb

CMD ["/usr/bin/zsh"]
