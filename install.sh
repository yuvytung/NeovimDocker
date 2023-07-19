docker build . -t yuvytung/neovim:latest
neovim='function neovim() {
  docker run -it --rm \
    -v "$(pwd)/:/root/workspace/" \
    -v ~/config_local/docker_neovim:/root \
    -e "ENV_USER_NAME=$(whoami)" \
    -e "ENV_USER_ID=$(id -u)" \
    -e "ENV_GROUP_ID=$(id -g)" \
    -e "ENV_FILE_PATH=$1" \
    yuvytung/neovim:latest
}
'
echo  "$neovim" >> ~/.bashrc
