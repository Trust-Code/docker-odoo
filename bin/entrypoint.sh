#!/usr/bin/env bash

if [ $UID -eq 0 ]; then

  echo "Iniciando o entrypoint com root"

  if [ -d /home/temp/.ssh ]; then

    ls -ld /home/temp/.ssh | awk '{print $3}'

    ODOO_USER_ID=$(ls -ld /home/temp/.ssh | awk '{print $3}')
    ODOO_GROUP_ID=$(ls -ld /home/temp/.ssh | awk '{print $4}')

    # adduser
    echo "Changing odoo user Id to be the same from host: $ODOO_USER_ID"
    usermod -u $ODOO_USER_ID odoo
    groupmod -g $ODOO_GROUP_ID odoo

    cp /home/temp/.ssh/id_rsa /opt/.ssh/id_rsa
    cp /home/temp/.ssh/id_rsa.pub /opt/.ssh/id_rsa.pub
    chmod 400 /opt/.ssh/id_rsa
    chmod 400 /opt/.ssh/id_rsa.pub
    chown odoo:odoo /opt/.ssh/id_rsa
    chown odoo:odoo /opt/.ssh/id_rsa.pub

    # Altera as permissões
    chown -R odoo:odoo /opt
    chown -R odoo:odoo /var/log/odoo
    chown odoo:odoo /etc/odoo/odoo.conf
    chown odoo:odoo /var/run/odoo.pid
    chown odoo:odoo /opt/odoo/autoupdate

  fi

  # Quando atualizando é bom deixar o log aparecer no terminal
  if [ $DISABLE_LOGFILE == 1 ]; then
    export LOG_FILE=False
  fi

  cd /opt/odoo
  chown odoo:odoo /etc/odoo/odoo.conf
  exec env su odoo "$0" -- "$@"

fi

export PATH="/opt/odoo:$PATH"
export PATH="/opt/odoo/odoo:$PATH"

echo "Iniciando o entrypoint com odoo"
cd /opt/odoo

# Se existir a chave tenta baixar os repositórios privados
if [ -f /opt/.ssh/id_rsa ]; then
  ssh-keyscan github.com >> ~/.ssh/known_hosts
  ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts

  if [ $ODOO_ENTERPRISE == 1 ]; then
    if [ ! -d enterprise ]; then
      git clone --single-branch -v -b $ODOO_VERSION git@github.com:Trust-Code/enterprise.git
    fi
  fi

fi

# Monta o addons_path
directories=$(ls -d -1 $PWD/**)
path=","
for directory in $directories; do
  if [ -d $directory ]; then
    if [ $directory != "/opt/odoo/odoo" ]; then
      path="$path""$directory",
    fi
  fi
done
export ADDONS_PATH="$path"

export ODOO_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# Modifica as variáveis do odoo.conf baseado em variáveis de ambiente
conf=$(cat odoo.conf | envsubst)
echo "$conf" > /etc/odoo/odoo.conf

exec "$@"
echo "Finalizou o entrypoint"
