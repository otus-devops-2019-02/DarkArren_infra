# DarkArren_infra
DarkArren Infra repository

<details>
  <summary>HomeWork 04 - Локальное окружение инженера. ChatOps и визуализация рабочих процессов. Командная работа с Git. Работа в GitHub</summary>

## HomeWork 04 - Локальное окружение инженера. ChatOps и визуализация рабочих процессов. Командная работа с Git. Работа в GitHub

- Добавлен Pull Request Template для GitHub
- Создан персональный канал в Slack и настроена интеграция с TravisCI
- Исправлена проблема с тестами Travis CI

</details>

<details>
  <summary>HomeWork 05 - Знакомство с облачной инфраструктурой. Google Cloud Platform </summary>

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

</details>

<details>
  <summary>HomeWork 06 - Деплой тестового приложения</summary>

## HomeWork 06 - Деплой тестового приложения

- Установил google-cloud-sdk `brew cask install google-cloud-sdk`
- Инициализировал glcoud через `glcoud init`
- Создал vm **reddit-app** через gcloud

<details>
  <summary>Create reddit-app vm</summary>

```bash
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure
```

</details>

- Подключился по SSH `ssh appuser@34.77.105.249`
- Установил Ruby и Bundler `sudo apt update && sudo apt install -y ruby-full ruby-bundler build-essential`
- Добавил ключи и репозиторий MongoDB `sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 &&
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'`
- Установил MongoDB `sudo apt update && sudo apt install -y mongodb-org`
- Запустил MongoDB и добавил автостарт `sudo systemctl start mongod && sudo systemctl enable mongod`
- Выкачал код приложения `git clone -b monolith https://github.com/express42/reddit.git`
- Установил зависимости `cd reddit && bundle install`
- Запустил сервер puma, проверил что он запустился `puma -d && ps aux | grep puma`
- Создал правило для puma-server (tcp 9292)
- Убедился что приложение доступно по <http://34.77.105.249>

### Самостоятельная работа

- Создан скрипт install_ruby.sh устанавливающий ruby

<details>
  <summary>install_ruby.sh</summary>

```bash
#!/bin/bash
apt update
apt install -y ruby-full ruby-bundler build-essential

```

</details>

- Создан скрипт install_mongodb.sh устанавливающий mongodb

<details>
  <summary>install_mongodb.sh</summary>

```bash
#!/bin/bash
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod

```

</details>

- Создан скрипт deploy.sh - загружающий код приложения, устанавливающий зависимости и запускающий приложение

<details>
  <summary>deploy.sh</summary>

```bash
#!/bin/bash
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d

```

</details>

### Дополнительное задание

- Создан startup_script.sh для настройки сервера, установки и запуска приложения

<details>
  <summary>startup_script.sh</summary>

```bash
#!/bin/bash
echo "Install Ruby"
apt update
apt install -y ruby-full ruby-bundler build-essential
echo "Install MongoDB"
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod
echo "Deploy reddit monolith"
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d

```

</details>

- Создание vm с использованием startup-script из файла

<details>
  <summary>startup-script from file</summary>

```bash
gcloud compute instances create reddit-app\
    --boot-disk-size=10GB \
    --image-family ubuntu-1604-lts \
    --image-project=ubuntu-os-cloud \
    --machine-type=g1-small \
    --zone=europe-west3-c \
    --tags puma-server \
    --restart-on-failure \
    --metadata-from-file startup-script=./startup_script.sh
```

</details>

- Создание инстанса с использование startup-script-url

<details>
  <summary>startup-script-url</summary>

```bash
gcloud compute instances create reddit-app\
    --boot-disk-size=10GB \
    --image-family ubuntu-1604-lts \
    --image-project=ubuntu-os-cloud \
    --machine-type=g1-small \
    --zone=europe-west3-c \
    --tags puma-server \
    --restart-on-failure \
    --metadata startup-script-url=https://uc0e5b58fe26d67541cbba141dbe.dl.dropboxusercontent.com/cd/0/inline/AiVa7NjvKFygSrCLh01ciNQmDB7mmrGT8pEInNhDLgNYeOQWZIJLZGgjkIJq4LmuRkVr-DWQttXySZMMCOO2iILKXUIjRTeRwPTqULgVcLP9hA/file#
```

</details>

- Создание firewall rule **default-puma-server** через gcloud

<details>
  <summary>create default-puma-server firewall rule</summary>

```bash
gcloud compute firewall-rules create default-puma-server\
    --network default \
    --priority 1000 \
    --direction ingress \
    --action allow \
    --target-tags puma-server \
    --source-ranges 0.0.0.0/0 \
    --rules TCP:9292
```

</details>

### IP-адрес и порт

testapp_IP = 34.77.105.249
testapp_port = 9292

</details>

## HomeWork 07 - Сборка образов VM при помощи Packer

- Установлен packer (1.4.1)
- Добавлен Application Default Credentials `gcloud auth application-default login`
- Создан шаблон для baked-image **ubuntu16.json**
- В шаблоне определены Packer builders
- В шаблон добавлены shell provisioners для установки Ruby и MongoDB
- Добавлены bash-скрипты для использования в shell provisioners
- Выполнена валидация щаблона: `packer validate ./ubuntu16.json`
- Выполнена сборка шаблона `packer build ubuntu16.json`
- Образ успешно создался и доступен в консоли GCP - Compute Engine - Images
- Приложение успешно установилось и запустилось на машине, созданной и подготовленного образа

### Самостоятельное задание

- В шаблон добавлен раздел variables, описывающий пользовательские переменные: project_id, source_image_family, machine_type
- Добавлен файл variables.json, содержащий определение пользовательских переменных
- Дополнительно параметризированы следующие значения: описание образа, размер и тип диска, название сети, теги
- Файл variables.json внесен в .gitignore, создан файл-заглушка variables.json.example
- Темплейт провалидирован и собран образ: `packer validate -var-file=variables.json ubuntu16.json && packer build -var-file=variables.json ubuntu16.json`

### Задание со звездочкой 1

- Добавлен шаблон immutable.json, созданный на основе шаблона ubuntu16.json
- Добавлен shell provisioner запускающий скрипт deploy.sh, который загружает и устанавливает приложение
- Добавлен file provisioner, который копирует на машину unit-файл **reddit.service**
- Добавлен shell provisioner, который копирует unit-файл в /etc/systemd/system и делает enable для сервиса
- Темплейт провалидирован и собран образ `packer validate -var-file=variables.json immutable.json && packer build -var-file=variables.json immutable.json`

### Задание со звездочкой 2

- Создан скрипт **create_reddit_vm.sh**, который, используя gcloud, создает виртуальную машину на основе образа reddit-full
