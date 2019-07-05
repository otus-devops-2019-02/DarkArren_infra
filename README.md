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

<details>
  <summary>HomeWork 08 - Практика IaC с использованием Terraform</summary>

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

</details>

<details>
  <summary>HomeWork 09 - Принципы организации инфраструктурного кода и работа над инфраструктурой в команде на примере Terraform</summary>

## HomeWork 09 - Принципы организации инфраструктурного кода и работа над инфраструктурой в команде на примере Terraform

- В **main.tf** добавлен ресурс **google_compute_firewall.firewall_ssh** для создания правила доступа по 22 порту
- При попытке выполнения `terraform apply` возникла ошибка, так как правило с такими параметрами уже существет в GCP
- Информации о существующем правиле **default-allow-ssh** добавлена в state терраформа `terraform import google_compute_firewall.firewall_ssh default-allow-ssh`
- В **main.tf** добавлен ресурс **google_compute_address.app_ip**
- Для создаваемого инстанса приложения определен ip_address в виде ссылки на созданный ресурс `nat_ip = "${google_compute_address.app_ip.address}"`

### Структуризация ресурсов

- При помощи Packer подготовлены образы **reddit-app-base** и **reddit-db-base**
- Созданы новые файлы **app.tf** с описанием ресурсов для инстанса с приложением и **db.tf** с описанием ресурсов для инстанса с MongoDB
- Создан **vpc.tf** с описанием ресурсов, применимых для всех инстансов
- Изменения спланированы и успешно применены

### Модули

- На основе **app.tf**, **db.tf** созданы соответствующие модули Terraform
- Удалены **app.tf** и **db.tf** из директории terraform
- В **main.tf** добавлены секции вызова модулей app и db
- Выполнена загрузка модулей в кэш Terraform (.terraform) `terraform get`
- Обнаружена проблема вывода outputs при запуске `terraform plan`
- В **outputs.tf** изменен вывод app_external_ip на переменную, получаемую из модуля app `value = "${module.app.app_external_ip}"`
- По аналогии с модулями app и db добавлен модуль vpc
- Инфраструктура развернута и проверено подключение по ssh к хостам reddit-app и reddit-db

### Параметризация модулей

- В модуле vpc параметризирован параметр source_ranges для ресурса google_compute_firewall
- Проверена функциональность фильтра по адресу, если в source_ranges указан не мой IP - доступ по ssh к хостам отсутствует, если указан мой адрес или 0.0.0.0/0 - доступ по ssh есть

### Переиспользование модулей

- Созданы директории для окружения stage и prod
- В main.tf в директориях для окружений изменены пути для локальной директории с модулями
- Для Stage параметр source range задан как 0.0.0.0/0, для prod - мой-внешний-адрес/32
- Проверена работа терраформ для разных окружений
- Удалены файл main.tf, outputs.tf, terraform.tfvars, variables.tf из директории terraform
- Для модулей app и db параметризированы значения machine_type и ssh_user

### Реестр модулей

- В директорию terraform добавлен файл **storage-bucket.tf**
- Проверено создание storage посредством запуска terraform

### HW09: Задание со звездочкой (*)

- Настроено хранение terraform state в google cloud storage:

<details>
  <summary>backend.tf</summary>

```go
terraform {
  backend "gcs" {
    bucket  = "storage-bucket-production"
    prefix  = "prod"
  }
}

```

</details>

- Проверена возможность запуска terraform apply из директории без terraform.tfstate

- При запуске одновременно из двух разных директорий срабатывает блокировка исполнения:

<details>
  <summary>state lock</summary>

```bash
Acquiring state lock. This may take a few moments...

Error: Error locking state: Error acquiring the state lock: writing "gs://storage-bucket-production/prod/default.tflock" failed: googleapi: Error 412: Precondition Failed, conditionNotMet
Lock Info:
  ID:        1548271474324722
  Path:      gs://storage-bucket-production/prod/default.tflock
  Operation: OperationTypeApply
  Who:       user@machine.local
  Version:   0.11.9
  Created:   2019-01-23 19:24:34.23497 +0000 UTC
  Info:


Terraform acquires a state lock to protect the state from being written
by multiple users at the same time. Please resolve the issue above and try
again. For most commands, you can disable locking with the "-lock=false"
flag, but this is not recommended.
```

</details>

### HW09: Задание с двумя звездочками (**)

- В модуль app добавлены provisioners:

<details>
  <summary>app module provisioner</summary>

```go
provisioner "file" {
  source      = "${path.module}/files/puma.service"
  destination = "/tmp/puma.service"
}

provisioner "remote-exec" {
  script = "${path.module}/files/deploy.sh"
}
provisioner "remote-exec" {
  inline = [
    "echo 'export DATABASE_URL=${var.db_internal_address}' >> ~/.profile",
    "export DATABASE_URL=${var.db_internal_address}",
    "sudo systemctl restart puma.service"
    ]
}
```

</details>

- Модуль app получает значение переменной db_internal_address из outputs модуля db, а затем, в процессе работы провижионера, добавляет это значение в переменные окружения, что позволяет приложениею reddit обратиться к базе данных MongoDB по правильному адресу

-В модуль db добавлен provisioner:

<details>
  <summary>db module provisioner</summary>

```go
provisioner "remote-exec" {
inline = [
  "sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf",
  "sudo systemctl restart mongod.service",
  ]
}
```

</details>

- В результате работы провижионера изменяется конфигурационный файл mongod.config, что позволяет подключаться к базе отовсюду.

</details>

<details>
  <summary>HomeWork 10 - Управление конфигурацией. Основные DevOps инструменты. Знакомство с Ansible</summary>

## HomeWork 10 - Управление конфигурацией. Основные DevOps инструменты. Знакомство с Ansible

- Установлен Ansible

<details>
  <summary>ansible --version</summary>

```bash
ansible 2.8.0
  config file = None
  configured module search path = ['/Users/4rren/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.7/site-packages/ansible
  executable location = /usr/local/bin/ansible
  python version = 3.7.3 (default, Mar 27 2019, 09:23:15) [Clang 10.0.1 (clang-1001.0.46.3)]
```

</details>

- Посредством Terraform развернута инфраструктура stage
- Создана inventory **ansible/inventory** с описанием машины appserver
- Проверена возможность подключения ansible к хосту appserver

<details>
  <summary> ansible appserver -m ping -i inventory</summary>

```bash
[DEPRECATION WARNING]: Distribution Ubuntu 16.04 on host appserver should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior Ansible releases. A future Ansible
release will default to using the discovered platform python for this host. See https://docs.ansible.com/ansible/2.8/reference_appendices/interpreter_discovery.html for more information. This feature
will be removed in version 2.12. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
appserver | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```

</details>

- В ansible/inventory добавлен хост dbserver, проверена возможность подключения Ansible к хосту dbserver `ansible dbserver -m ping -i inventory`
- Настроен ansible.cfg
- Получены данные об uptime сервера БД `ansible dbserver -m command -a uptime`
- В инвентори добавлены группы хостов app и db
- Добавлена yaml-инвентори, проверена доступность хостов в группах
- Исследована работа модулей shell и command
- Исследована работа модулей systemd и service
- Исследована работа модуля git в сравнении с модулем command
- Добавлен плейбук clone.yml
- Результат первого запуска

<details>
  <summary>ansible-playbook clone.yml</summary>

```bash
PLAY [Clone] **************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
ok: [appserver]

TASK [Clone repo] *********************************************************************************************************************
ok: [appserver]

PLAY RECAP ****************************************************************************************************************************
appserver                  : ok=2    changed=0    unreachable=0    failed=0
```

</details>

- Второй запуск - после выполнения `ansible app -m command -a 'rm -rf ~/reddit'`

<details>
  <summary>ansible-playbook clone.yml</summary>

```bash
PLAY [Clone] **************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
ok: [appserver]

TASK [Clone repo] *********************************************************************************************************************
changed: [appserver]

PLAY RECAP ****************************************************************************************************************************
appserver                  : ok=2    changed=1    unreachable=0    failed=0
```

</details>

- После удаления директории reddit и повторного запуска плейбка clone.yml изменился статус после сообщения. В первом случае папка уже была, поэтому выполнение плейбука, по сути, не вносило никаких изменений. Во втором случае - репозиторий был загружен, соответственно второй таск внес изменения, что и отобразилось в логе.

### HW10: Задание со *

- Добавлен файл в формате динамического инвентори - inventory.json

<details>
  <summary>inventory.json</summary>

```json
{
    "app": {
        "hosts": ["appserver"]
    },
    "db": {
        "hosts": ["dbserver"]
    },
    "_meta": {
        "hostvars": {
            "appserver": {
                "ansible_host" : "34.77.213.46"
            },
            "dbserver": {
                "ansible_host": "35.240.15.8"
            }
        }
    }
}
```

</details>

- Добавлен "скрипт для формирования динамического инвентори, лол"

<details>
  <summary>dynamic_inventory.json</summary>

```bash
#!/bin/bash
cat ./inventory.json
```

</details>

- dynamin_inventory.json помечен как исполняемый
- Проверена работоспособность c использованием скрипта динамического инвентор

<details>
  <summary>ansible all -m ping -i dynamic_inventory.json</summary>

```bash
ansible all -m ping -i dynamic_inventory.sh
[DEPRECATION WARNING]: Distribution Ubuntu 16.04 on host dbserver should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior Ansible releases. A future Ansible
release will default to using the discovered platform python for this host. See https://docs.ansible.com/ansible/2.8/reference_appendices/interpreter_discovery.html for more information. This feature
will be removed in version 2.12. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
dbserver | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
[DEPRECATION WARNING]: Distribution Ubuntu 16.04 on host appserver should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior Ansible releases. A future Ansible
release will default to using the discovered platform python for this host. See https://docs.ansible.com/ansible/2.8/reference_appendices/interpreter_discovery.html for more information. This feature
will be removed in version 2.12. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
appserver | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```

</details>

</details>

## HomeWork 11 - Деплой и управлений конфигурацией с Ansible

- Закомментирован код провижининга для модулей Terraform

### Один плейбук, один сценарий

- В .gitignore добавлен `*.retry`
- В плейбук reddit-app.yml добавлен сценарий для конфигурирования MongoDB с использованием шаблона конфигурационного файла и отдельного тега db-tag
- Добавлен jinja-шаблон для mongodb - mongod.conf.j2
- При тестовом запуске плейбука выявлена ошибка AnsibleUndefinedVariable `ansible-playbook reddit_app.yml --check --limit db`
- В плейбук добавлено значение переменной mongo_bind_ip, повторная проверка прошла успешно
- В плейбук добавлен handler restart mongod, осуществляющий перезапуск сервиса, если были произведены изменения
- Плейбук применился успешно

### Настройка инстанса приложения

- Добавлен unit-file puma.service
- В сценарий добавлены таски для копирования unit-файла puma.service на хост и автозапуска puma
- Добавлен handler для перезапуска puma.service
- Добавлен шаблон для конф-файла puma.service
- Добавлен таск копирования шаблона с параметром для db connection
- В сценарий добавлен параметр db_host
- Применены изменения добавленные в плейбук `ansible-playbook reddit_app.yml --limit app --tags app-tag`

### Деплой

- Добавлены таски для клонирования репозитория reddit и установки зависимостей через bundle install, таски помечены тегом deploy-tag
- Применены изменения описанные в тасках с deploy-tag
- Проверена доступность приложения в браузере

### Один плейбук, несколько сценариев

- Создан новый плейбук reddit_app2.yml
- В новый плейбук в отдельный play перенесены все таски связанные с настройкой MongoDB
- В новый плейбук в отдельный play перенесены таски, связанные с настройкой приложения
- Пересоздана инфраструктура `terraform destroy -auto-approve && terraform apply -auto-approve`
- Сценарии применены к обновленной инфраструктуре `ansible-playbook reddit_app2.yml --tags db-tag` и `ansible-playbook reddit_app2.yml --tags app-tag`
- В плейбук reddit_app2.yml добавлен сценарий (таски) для деплоя приложения
- Приложение задеплоено запуском плейбука `ansible-playbook reddit_app2.yml --tags deploy-tag`

### Несколько плейбуков

- Добавлены новые плейбуки app.yml, db.yml, deploy.yml, плейбуки reddit_app.yml и reddit_app2.yml переименованы
- Сценарии разнесены по отдельным плейбукам
- Создан общий плейбук site.yml, в который импортированы плейбуки app, db, deploy
- Проверена работа плейбука site.yml на чистой инфраструктуре

### HW11: Задание со *

- В качестве инструмента для работы с динамическим инвентори выбран gce.py, решающими факторами было то что, это популярный инструмент, написан на знакомом языке, есть некоторый опыт работы с gce.py
- Создан сервисный пользователь, произведена конфигурация посредством gce.ini, json-ключа сервисного пользователя и env_var GCE_INI_PATH
- В ansible.cfg изменен параметр inventory `inventory = ./gce.py`
- В плейбуках группы хостов app и db заменены на tag_reddit-app и tag_reddit-db

### Провижининг в Packer

- Добавлены плейбуки packer_app.yml и packer_db.yml
- В шаблонах packer provisioner shell заменен на provisioner ansible
- Образы пересобраны с использованием измененных шаблонов packer
- Инфраструктура пересоздана и развернуто приложение с использование плейбука site.yml
