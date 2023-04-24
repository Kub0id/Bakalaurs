#!/bin/bash
# Install docker
apt update && apt upgrade -y
apt-get install ca-certificates curl gnupg -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Edit Config
echo "Ievadi VPN lietotāju skaitu no 1 līdz 244"
read USERS
if ! [[ "$USERS" =~ ^[0-9]+$ ]] ;
 then exec >&2; echo "Kļūda, nav cipars"; exit 1
fi
sed -i "s/PEERS=1.*/PEERS=$USERS/g" docker-compose.yml
PASS=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 12 ; echo '')
sed -i "s/MYSQL_PASSWORD=.*/MYSQL_PASSWORD=$PASS/g" docker-compose.yml
PASS=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 12 ; echo '')
sed -i "s/MYSQL_ROOT_PASSWORD=.*/MYSQL_ROOT_PASSWORD=$PASS/g" docker-compose.yml

# Make containers
docker compose up -d
