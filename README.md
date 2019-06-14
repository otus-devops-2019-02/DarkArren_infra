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

<details>
  <summary>HomeWork 07 - Сборка образов VM при помощи Packer</summary>

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

</details>

## HomeWork 08 - Практика IaC с использованием Terraform

- Удален SSH-ключ пользователя appuser из Compute Engine - Metadata - SSH keys
- Установлен Terraform v0.11.11
- Создан конфигурационный файл **terraform/main.tf**
- Добавлены terraform-related исключения в .gitignore
- В **main.tf** добавлено описание провайдера GCP
- Выполнена инициализация модулей Terraform `cd terraform && terraform init`
- В **main.tf** добавлен ресурс **google_compute_instance** для создания vm в GCP
- Проведена валидация планируемых изменений `terraform plan`
- Применены запланированные изменения `terraform apply`
- Получен IP-адрес инстанса из tfstate-файла `terraform show | grep nat_ip`
- Произведена попытка подключения к инстансу по SSH `ssh appuser@34.77.176.212`, подключение не удалось
- В **main.tf** в описание ресурса добавлен раздел metadata, содержащий путь к публичному ключу

<details>
  <summary>ssh metadata</summary>

```bash
metadata {
  # путь до публичного ключа
  ssh-keys = "appuser:${file("~/.ssh/appuser.pub")}"
}
```

</details>

- Изменения проверены и применены к инстансу `terraform plan && terraform apply -auto-approve`
- Проверено подключение к инстансу по SSH, подключение прошло успешно
- Добавлен файл выходных переменных **outputs.tf**
- Добавлена выходная переменна app_external_ip `google_compute_instance.app.network_interface.0.access_config.0.nat_ip`
- Получено значение переменной после выполнения `terraform refresh` и `terraform output`
- Добавлено описание ресурса google_compute_firewall, создающее правило, которое разрешает доступ на 9292 порт
- Изменения применены, создано правило для firewall в GCP
- Добавлен тэг `tags = ["reddit-app"]` для инстанса **google_compute_instance.app**

### Provisioners

- Для ресурса **google_compute_instance.app** добавлен provisioner типа file, который будет копировать файл с локальной машины на создаваемый инстанс

<details>
  <summary>file provisioner</summary>

```ruby
provisioner "file" {
    source = "files/puma.service"
    destination = "/tmp/puma.service"
}
```

</details>

- Для ресурса **google_compute_instance.app** добавлен provisioner типа remote_exec, который будет запускать bash-скрипт на создаваемом инстансе

<details>
  <summary>remote_exec provisioner</summary>

```ruby
provisioner "remote-exec" {
    script = "files/deploy.sh"
}
```

</details>

- Внутрь описания ресурса **google_compute_instance.app** добавлен раздел connection, который определеяет параметры подключения к инстансу для запуска провижионеров

<details>
  <summary>provisioner connection</summary>

```ruby
connection {
  type = "ssh"
  user = "appuser"
  agent = false
  # путь до приватного ключа
  private_key = "${file("~/.ssh/appuser")}"
}
```

</details>

- Т.к. провижионеры запускаются только при создании нового ресурса (или при удалении), то, для выполнения секций провижионинга, ресурс **google_compute_instance.app** помечен для перес оздания при слудеющем применении изменений `terraform taint google_compute_instance.app`
- После применения изменений можно убедитсья, что приложение reddit доступно по <http://your-vm-ip:9292>

### Input Vars

- Добавлен файл под input vars - **variables.tf**
- В файл переменных terraform добавлены переменные: project, region, public_key_path, disk_image
- В файле **main.tf** значения параметров project, region, public_key_path. disk_image изменены на переменные
- Значения переменных, которые не имеют дефолтного значения, определены в файле **terraform.tfvars**
- Инфраструктура пересоздана посредством выполнения команд `terraform destroy -auto-approve && terraform plan && terraform apply -auto-approve`
- После пересоздания приложения доступно по  <http://your-vm-ip:9292>

### Самостоятельное задание

- Определена переменная private_key_path которая используется для подключения провижионеров в ресурсе **google_compute_instance.app**
- Определена переменная zone, которая имеет дефолтное значение и используется в ресурсе **google_compute_instance.app**
- Все файл отформатированы `terraform fmt .`
- Добавлен шаблон переменных **terraform.tfvars.example**

### Задание со звездочкой (*)

- Добавление ключа пользователя в Compute Engine - Metadata

<details>
  <summary>add ssh key for 1 user</summary>

```ruby
resource "google_compute_project_metadata" "default" {
  metadata {
    ssh-keys = "abramov1:${file(var.public_key_path)}"
  }
}
```

</details>

- Добавление ключей нескольких пользователей в Compute Engine - Metadata

<details>
  <summary>Add ssh key for 5 users</summary>

```bash
resource "google_compute_project_metadata" "default" {
  metadata {
    ssh-keys = "appuser1:${file(var.public_key_path)} appuser2:${file(var.public_key_path)} appuser3:${file(var.public_key_path)} appuser4:${file(var.public_key_path)} appuser5:${file(var.public_key_path)}"
  }
}
```

</details>

- В метаданные проекта добавлен ssh-ключ для пользователя appuser_web
- После применения `terraform apply` была обнаружена проблема: ключ пользователя appuser_web был удален из метаданных проекта, остались только те ключи, которые описаны в terraform

### Задание с двумя звездочками (**)

- Добавлен файл **lb.tf** описывающий создание балансировщика для http
- В outputs добавлен вывод ip адреса балансировщика
- Добавлено создание еще одного инстанса, неудобство - копирование кода ведет к разрастанию файла и возможным ошибкам и неодинаковости инстансов
- Добавлено создание второго инстанса с приложением через count
- Добавлено автоматическое добавление инстансов в target_pool
- Добавлен вывод в outputs ip-адресов созданных инстансов
