# Дипломная работа по профессии «Системный администратор» - Колобов Михаил

---
### ПОДГОТОВИТЕЛЬНАЯ ЧАСТЬ
#### На VirtualBox создаю ВМ, используемая ОС Debian11 ***(параллельно все действия проверял на реально работающей машине с аналогичной ОС)***

#### Проверяю обновления

`sudo apt update`

`sudo apt upgrade`

`sudo apt full-upgrade`

#### Устанавливаю ANSIBLE
***(более недели провел на полях инета в поисках инфы которая сможет доступно разжевать почему эта шайтан машина не хочет работать))), просмотр первого урока (практическая часть) от ментора вгонял в уныние)***
`python --version`

`python3 --version`

`update-alternatives --install /usr/bin/python python /usr/bin/python3 2`

`python --version`

`sudo apt install git python3-pip`

`pip3 install yml`

`pip3 install ansible`

`ansible --version`

#### Устанавливаю TERRAFORM
***(за время выполнения этого аттракциона у TERRAFORM вышло 3-и версии)***

`mkdir terraform_setup`

`cd terraform_setup`

`wget https://hashicorp-releases.yandexcloud.net/terraform/1.6.2/terraform_1.6.2_linux_amd64.zip`

`zcat terraform_1.6.2_linux_amd64.zip > terraform`

`file terraform`

`chmod 766 terraform`

`./terraform -v`

`cp terraform /usr/local/bin/`

`terraform -v`

`cd`

#### Настраиваю TERRAFORM

`nano ~/.terraformrc`

```
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```

`mkdir terraform`

`cd terraform`

`nano main.tf`

```
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token = "y0_AgAAAAATsxVZAATuwQAAAADinqT3jXuJN8aPSkGeJzd-4gZxKkGjwZ4"
  cloud_id = "b1g09ilem72537mh3ies"
  folder_id = "b1gv1df2r3960gt3bb4j"
}
```

`terraform providers lock -net-mirror=https://terraform-mirror.yandexcloud.net -platform=linux_amd64 -platform=darwin_arm64 yandex-cloud/yandex`

`terraform init`

`cd`

#### Устанавливаю nginx (https://nginx.org/ru/linux_packages.html#Debian)
***https://nginx.org/ru/linux_packages.html#instructions***

`sudo apt install curl gnupg2 ca-certificates lsb-release debian-archive-keyring`

`curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null`

Проверяю, верный ли ключ был загружен:
`gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg`

```
Вывод команды должен содержать полный отпечаток ключа 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62:
pub   rsa2048 2011-08-19 [SC] [expires: 2024-06-14]
      573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
uid                      nginx signing key <signing-key@nginx.com>
```

`echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/debian `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list`

#### Чтобы установить nginx, выполните следующие команды:

`sudo apt update`

`sudo apt upgrade`

`sudo apt install nginx`

`service nginx start`

`service nginx status`

`apt show nginx`

#### Создаю SSH ключ

`sudo apt install openssh-server`

`mkdir /root/ansible`

`mkdir /root/ansible/.ssh/`

`ssh-keygen -t rsa`

`/root/ansible/.ssh/mykey`
`cat /root/ansible/.ssh/mykey.pub`

`cd /root/ansible/.ssh`

`chmod 0400 mykey*` – из личного опыта это действие позволяет быстрее подружиться с ANSIBLE

`cd`

### ОСНОВНАЯ ЧАСТЬ

## САЙТ

#### Завершаю настройки terraform

`cd terraform`

`nano meta.txt`

```
#cloud-config
users:
 - name: mikhail
   groups: sudo
   shell: /bin/bash
   sudo: ['ALL=(ALL) NOPASSWD:ALL']
   ssh-authorized-keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDVQfNNv0Q+94+nVE77yA6-----------------------fnVz+g5RLo0QNmdRpS4pJvGgUovAoZ8Z1sjuASYLXy29b9E= root@mikhail
```

`terraform validate`

`terraform plan`

#### Устанавливаю две ВМ в разных зонах

`nano website1.tf`

```
resource "yandex_compute_instance" "website-a" {
  name                      = "website1"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-a"

  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd87gocdmk3tosg6onpg"
      size = 10
      description = "boot disk for nginx_server1"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-a.id}"
    nat       = true
  }

  metadata = {
    user-data = "${file("~/terraform/meta.txt")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_vpc_network" "network-a" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-a" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = "${yandex_vpc_network.network-a.id}"
}
```
`terraform validate`

`terraform plan`

`nano website2.tf`

```
resource "yandex_compute_instance" "website-b" {
  name                      = "website2"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-b"

  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd87gocdmk3tosg6onpg"
      size = 10
      description = "boot disk for nginx_server1"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-b.id}"
    nat       = true
  }

  metadata = {
    user-data = "${file("~/terraform/meta.txt")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_vpc_subnet" "subnet-b" {
  name           = "subnet2"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["192.168.20.0/24"]
  network_id     = "${yandex_vpc_network.network-a.id}"
}
```

`terraform validate`

`terraform plan`

`nano target_backend_group.tf`

```
resource "yandex_alb_target_group" "target-group" {
  name           = "nginxweb-target-group"
  description    = "ALB:Target group"
  target {
    subnet_id    = yandex_vpc_subnet.subnet-a.id
    ip_address   = yandex_compute_instance.website-a.network_interface.0.ip_address
  }

  target {
    subnet_id    = yandex_vpc_subnet.subnet-b.id
    ip_address   = yandex_compute_instance.website-b.network_interface.0.ip_address
  }
}

resource "yandex_alb_http_router" "http-router" {
  name          = "nginxweb-http-router"
  description   = "ALB:HTTP router"
}


resource "yandex_alb_load_balancer" "target-backend-group" {
  name        = "nginxweb-target-backend-group"
  description = "ALB:Target backend group"
  network_id  = "${yandex_vpc_network.network-a.id}"

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = "${yandex_vpc_subnet.subnet-a.id}"
    }
  }

  listener {
    name = "listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = "${yandex_alb_http_router.http-router.id}"
      }
    }
  }
}
```

`terraform validate`

`terraform plan`

`cd`

##### Создаю файл ansible.cfg

`cd ansible`

`ansible-config init --disabled -t all > ansible.cfg` *– генерация полностью закоммент. файла с существующими плагинами*

`ansible --version`

##### Редактирую ansible.cfg

`nano ansible.cfg`

```
[defaults]
host_key_checking = false
inventory         = ./hosts.txt
```

##### С помощью ANSIBLE подключаюсь к созданным ВМ на yandex cloud

`nano hosts.txt`

```
[website]
website1 ansible_host=158.160.123.189 ansible_user=mikhail ansible_ssh_private_key_file=/root/ansible/.ssh/mykey
website2 ansible_host=158.160.85.47 ansible_user=mikhail ansible_ssh_private_key_file=/root/ansible/.ssh/mykey
```
##### Проверяю работу ansible *(он завёлся, и я не удержался побаловаться с командами)*
`ansible all -m ping`

`ansible all --list-hosts`

`ansible-inventory --graph`

`ansible-inventory --list`

`ansible all -m setup`
`ansible -m ping all -u ansible -k`

`ansible all -m shell -a "uptime"`

`ansible all -m shell -a "ls /etc"`

`echo privet > privet.txt` *– создаю файл для теста*

`ansible all -m copy -a "src=privet.txt dest=/home"` -b *– пример записи файла на управляемые машины*

`ansible all -m shell -a "ls -la /home"` *– проверяю как прошла записи файла на управляемых машинах*

`ansible all -m file -a "path=/home/privet.txt state=absent" -b` *– удаляю записанный файл на управляемых машинах*

`ansible all -m get_url -a "url=https://hashicorp-releases.yandexcloud.net/terraform/1.6.2/terraform_1.6.2_linux_amd64.zip dest=/home"` -b *– пример записи файла из интернета на управляемые машины*

##### Создаю playbook для обновления ВМ *(громко сказано СОЗДАЮ, проще сказать взял шаблон из инета)*

nano 00_update_playbook.yml






`
***

```

```
