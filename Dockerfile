FROM ubuntu:jammy-20230605
# env
ENV NODE_VERSION=16.20.1
ENV JAVA_VERSION=17
ENV WORK_USER=root
ENV HOME=/root
ENV WORK_DIR=$HOME/workspace
ENV TEMP_DIR=$HOME/tmp
# base
SHELL ["/bin/bash", "-c"]
RUN apt update -y && apt upgrade -y
RUN apt install -y \
    git ripgrep unzip \
    curl wget \
    python3-pip python3 python3.10-venv
USER $WORK_USER
RUN mkdir $TEMP_DIR 
WORKDIR $TEMP_DIR
# zsh
RUN curl -Lo- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh | bash
SHELL ["/bin/zsh", "--login", "-c"]
# nvm node
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash && \
    echo 'export NVM_DIR="$HOME/.nvm"\n\
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm\n\
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> ~/.zshrc && \
    source ~/.zshrc && \
    nvm install $NODE_VERSION && \
    nvm use default $NODE_VERSION
# java
RUN curl -Lo $TEMP_DIR/amazon-corretto-$JAVA_VERSION.tar.gz \
    https://corretto.aws/downloads/latest/amazon-corretto-$JAVA_VERSION-x64-linux-jdk.tar.gz
RUN mkdir ~/java && \
    tar -xzf $TEMP_DIR/amazon-corretto-$JAVA_VERSION.tar.gz -C ~/java/ && \
    JAVA_HOME=$(ls ~/java | grep $JAVA_VERSION | xargs -I {arg} echo "$HOME/java/{arg}") && \
    echo "export JAVA_HOME=$JAVA_HOME" >> ~/.zshrc && \
    echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.zshrc 
# neovim
RUN curl -Lo $TEMP_DIR/neovim.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz && \
    tar -xzf $TEMP_DIR/neovim.tar.gz -C $TEMP_DIR/  && cp -rp $TEMP_DIR/nvim* ~/neovim  && \
    echo 'export PATH=$HOME/neovim/bin:$PATH' >> ~/.zshrc && \
    git clone https://github.com/NvChad/NvChad ~/.config/nvim


RUN rm -rf $TEMP_DIR
RUN mkdir /init_home && \
    mv $HOME/{.,}* /init_home/ && \
    cd /init_home && chmod -R 775 $(ls -AI '.oh-my-zsh')
RUN echo '%su ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo 'root:root' | chpasswd
WORKDIR $WORK_DIR
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/zsh", "-uelic", "/entrypoint.sh"]

