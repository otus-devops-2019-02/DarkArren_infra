# DarkArren_infra
DarkArren Infra repository

<details>
  <summary>HomeWork 04 - Локальное окружение инженера. ChatOps и визуализация рабочих процессов. Командная работа с Git. Работа в GitHub</summary>

## HomeWork 04 - Локальное окружение инженера. ChatOps и визуализация рабочих процессов. Командная работа с Git. Работа в GitHub

- Добавлен Pull Request Template для GitHub
- Создан персональный канал в Slack и настроена интеграция с TravisCI
- Исправлена проблема с тестами Travis CI

</details>

## HomeWork 05 - Знакомство с облачной инфраструктурой. Google Cloud Platform

- Создана учетная запись в GCP, активирован trial
- Создан проект Infra в GCP
- Созданы ключи для пользователя appuser, который будет использоваться для подключения к VM в облаке `ssh-keygen -t rsa -f ~/.ssh/appuser -C appuser -P ""`
- Добавлен ключ appuser в Compute Engine - Metadata - SSH Keys
- Создана VM **bastion**
- Проверено подключение к VM bastion `ssh -i ~/.ssh/appuser appuser@34.77.105.249`
- Создана VM **someinternalhost** без публичного адреса
- Убедился что подключение с bastion на someinternalhost невозможно
- Добавил ключ appuser для форвардинга `ssh-add ~/.ssh/appuser`
- Подключился к bastion `ssh -i ~/.ssh/appuser -A appuser@34.77.105.249`
- Подключился с bastion к someinternalhost `ssh 10.132.0.4`

### Самостоятельное задание

- Подключение к someinternalhost одной командой `ssh -J appuser@34.77.105.249 appuser@10.132.0.4`
- Подключение к someinternalhost через alias: добавить в ~/.ssh/config

<details>
  <summary>Update SSH config</summary>

```bash
Host bastion
    HostName 34.77.105.249
    User appuser

Host someinternalhost
    HostName 10.132.0.4
    User appuser
    ProxyJump bastion
```

</details>

### Настройка Pritunl

- Для **bastion** добавлены правила, разрешающие HTTP/HTTPS
- Создан скрипт setupvpn.sh

<details>
  <summary>setupvpn.sh</summary>

```bash
cat <<EOF> setupvpn.sh
#!/bin/bash
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.4.list
echo "deb http://repo.pritunl.com/stable/apt xenial main" > /etc/apt/sources.list.d/pritunl.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 0C49F3730359A14518585931BC711F9BA15703C6
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
apt-get --assume-yes update
apt-get --assume-yes upgrade
apt-get --assume-yes install pritunl mongodb-org
systemctl start pritunl mongod
systemctl enable pritunl mongod
EOF
```

</details>

- Выполнена установка MongoDB и Pritunl `sudo bash setupvpn.sh`
- Выполнена настройка VPN-сервера: изменен пароль администратора, создана организация, добавлен пользователь test, создан сервер и выполнена привязка к организации
- Создано правило vpn-11794, разрешающие подключение из 0.0.0.0/0 к UDP 11794
- Для машины **bastion** добавлен network-tag **vpn-11794**
- Посредством Tunnelbrick проверил подключение к vpn-серверу
- Убедился что возможно подключение к **someinternalhost** по внутреннему IP `ssh -i ~/.ssh/appuser appuser@10.132.0.4`


### Дополнительное задание

- Добавил скрипт установки certbot

<details>
  <summary>setupcertbot.sh</summary>

```bash
cat <<EOF> setupcertbot.sh
#!/bin/bash
apt-get update
apt-get install software-properties-common -y
add-apt-repository universe -y
add-apt-repository ppa:certbot/certbot -y
apt-get update
apt-get install certbot -y
EOF
```

</details>

- Установил certbot `sudo bash setupcertbot.sh`
- Создал сертификат `sudo certbot certonly` с использованием адреса: 34.77.105.249.sslip.io
- Через web-интерфейс в настройках сервера указал Lets Encrypt Domain - 34.77.105.249.sslip.io

### IP-адреса хостов

bastion_IP = 34.77.105.249
someinternalhost_IP = 10.132.0.4
