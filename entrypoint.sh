#!/bin/zsh
ENV_USER_NAME=$ENV_USER_NAME || "user"
ENV_USER_ID=$ENV_USER_ID || "1000"
ENV_GROUP_ID=$ENV_GROUP_ID || "1000"
ENV_FILE_PATH=$ENV_FILE_PATH || ""
echo "Neovim" 
if ! [[ "$(ls -A -I 'workspace' -I 'tmp' -I '.zcompdump*' /root)" ]] ;
then
  echo "Initialize new configuration."
  cd /init_home && mv $(ls -A -I workspace -I tmp -I ".zcompdump*" /init_home) /root/
else
    echo "Use current configuration."
fi

if ! [[ $ENV_USER_ID -eq "0" ]] ;
then
  groupadd --gid "$ENV_GROUP_ID" "$ENV_USER_NAME"
  useradd -d /root \
    --shell /bin/zsh \
    --uid "$ENV_USER_ID" \
    --gid "$ENV_GROUP_ID" \
    -G root "$ENV_USER_NAME"
fi


su "$ENV_USER_NAME" \
  -c "source /root/.zshrc
  cd /root/workspace/
  nvim $ENV_FILE_PATH"
echo Goodbye!
