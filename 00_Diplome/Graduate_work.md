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

`nano 00_update_playbook.yml`

```
---
- hosts: all
  become: true
  tasks:

    - name: Update and upgrade apt packages
      apt:
        update_cache: yes
        upgrade: yes
```

`ansible-playbook 00_update_playbook.yml`

##### Создаю playbook для установки nginx на ВМ 

`nano 01_nginx_playbook.yml`

```
# МОЙ ПЕРВЫЙ РАБОТАЮЩИЙ PLAYBOOK
---
- hosts: website
  become: true
  tasks:

    - name: update
      apt: update_cache=yes

    - name: Install Nginx
      apt: name=nginx state=latest

      notify:
        - restart nginx

    - name: ensure nginx is at the latest version
      apt: name=nginx state=latest
    - name: start nginx
      service:
          name: nginx
          state: started

  handlers:
    - name: restart nginx
      service: name=nginx state=reloaded
```

`ansible-playbook 01_nginx_playbook.yml`

##### Круто, тестирование проходит сразу после установки nginx на ВМ (скрины использованы из многочисленных попыток)

`sudo nano /usr/share/nginx/html/index.html`

```
<!DOCTYPE html>
<html>
<head>


<span class="heading-primary-main">My thesis page!</span>
<title>Graduate work</title>
<style>
html { color-scheme: light green; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>"Graduate work"</h1>

<h1>"Topic by profession"</h1>

<h1>"System Administrator"</h1>

<h1>"Mikhail Kolobov"</h1>

<p>What have I done, my brain explodes, in a few weeks I had to rethink most of the course several times!!!</p>

<p><em>Thank you for your hard work, it was fascinating!!!</em></p>
</body>
</html>
```

`curl -v 158.160.62.234:80`

`curl -v 158.160.29.143:80`

1. ![00_NGINX](https://github.com/Mikhail-2023/06_The_final_module_of_the_profession_is_a_System_administrator/blob/main/00_Diplome/Scans_of_diplomas/01_screen_site/00_NGINX.PNG)
2. ![01_NGINX](https://github.com/Mikhail-2023/06_The_final_module_of_the_profession_is_a_System_administrator/blob/main/00_Diplome/Scans_of_diplomas/01_screen_site/01_NGINX.PNG)
3. ![01-01_NGINX](https://github.com/Mikhail-2023/06_The_final_module_of_the_profession_is_a_System_administrator/blob/main/00_Diplome/Scans_of_diplomas/01_screen_site/01-01_NGINX.PNG)
4. ![02_NGINX](https://github.com/Mikhail-2023/06_The_final_module_of_the_profession_is_a_System_administrator/blob/main/00_Diplome/Scans_of_diplomas/01_screen_site/02_NGINX.PNG)
5. ![03_NGINX](https://github.com/Mikhail-2023/06_The_final_module_of_the_profession_is_a_System_administrator/blob/main/00_Diplome/Scans_of_diplomas/01_screen_site/03_NGINX.PNG)
6. ![03-02_NGINX](https://github.com/Mikhail-2023/06_The_final_module_of_the_profession_is_a_System_administrator/blob/main/00_Diplome/Scans_of_diplomas/01_screen_site/03-02_NGINX.PNG)

## МОНИТОРИНГ

##### Устанавливаю ВМ

`cd terraform`

`nano monitoring.tf`

```
resource "yandex_compute_instance" "zabbix-1" {
  name                      = "zabbix1"
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
      description = "boot disk for zabbix-1"
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
```

`terraform validate`

`terraform plan`

`terraform apply`

`cd`

##### На все машины которые будут подключены к Zabbix устанавливаю PostgreSQL:

##### Добавляю в файл `hosts` новую группу `monitoring_agent`
`nano hosts.txt`

```
...
[monitoring_agent]
website1 ansible_host=158.160.123.189 ansible_user=mikhail ansible_ssh_private_key_file=/root/ansible/.ssh/mykey
website2 ansible_host=158.160.85.47 ansible_user=mikhail ansible_ssh_private_key_file=/root/ansible/.ssh/mykey
zabbix1 ansible_host=158.160.107.130 ansible_user=mikhail ansible_ssh_private_key_file=/root/ansible/.ssh/mykey
```

nano 02_postgresql_playbook.yml

```
---

- hosts: monitoring_agent
  become: true
  tasks:

    - name: update
      apt: update_cache=yes

    - name: Install PostgreSQL
      apt: name=postgresql state=latest
```

`ansible-playbook 02_postgresql_playbook.yml`

##### На ВМ находящиеся в Yandex Cloud устанавливаю Zabbix

`cd ansible`

###### С помощью `ansible-galaxy` инициализирую роль `zabbix_agent`

`ansible-galaxy init zabbix_agent`

`nano zabbix_agent/tasks/main.yml`

```
---
# tasks file for zabbix_agent

- name: Install Zabbix 6.4 Debian repo .deb
  ansible.builtin.apt:
    deb: https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian11_all.deb

- name: Install Zabbix Agent 6.4
  ansible.builtin.apt:
    name: zabbix-agent2
    state: present
    update_cache: yes
```

`nano 03_zabbix_agent_playbook.yml`

```
---

- name: Install Zabbix Agent 6.4
  hosts: monitoring_agent
  become: true
  roles:
    - zabbix_agent

...
```

`ansible-playbook 03_zabbix_agent_playbook.yml`

Подключаюсь к Zabbix через браузер и авторизуюсь
`http://130.193.38.140/zabbix/`

## ЛОГИ

##### Устанавливаю ВМ

`cd terraform`

`nano elasticsearch.tf`

```
resource "yandex_compute_instance" "elasticsearch-1" {
  name                      = "elasticsearch1"
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
      description = "boot disk for elasticsearch-1"
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
```
`terraform validate`

`terraform plan`

`nano kibana.tf`

```
resource "yandex_compute_instance" "kibana-1" {
  name                      = "kibana1"
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
      description = "boot disk for kibana-1"
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
```

`terraform validate`

`terraform plan`

`terraform apply`

`cd`

`cd ansible`

##### Добавляю в файл hosts новую группу LOGS
`nano hosts.txt`

```
...

[logs]
elasticsearch1 ansible_host=158.160.64.228 ansible_user=mikhail ansible_ssh_private_key_file=/root/ansible/.ssh/mykey
kibana1 ansible_host=51.250.16.110 ansible_user=mikhail ansible_ssh_private_key_file=/root/ansible/.ssh/mykey
```

`ansible -i hosts.txt all -m ping`

##### Проверяю обновления на ВМ

`ansible-playbook 00_update_playbook.yml`

С помощью `ansible-galaxy` инициализирую роль `elasticsearch`

`ansible-galaxy init elasticsearch`

`nano elasticsearch/tasks/main.yml`

```
---
# tasks file for elasticsearch

- name: Update apt cache
  apt:
    update_cache: yes

- name: Ensure dependencies are installed.
  apt:
    name:
      - apt-transport-https
      - gnupg2
    state: present

- name: Get elasticsearch 8.6.2
  ansible.builtin.get_url:
    url: https://mirror.yandex.ru/mirrors/elastic/8/pool/main/e/elasticsearch/elasticsearch-8.6.2-amd64.deb
    dest: /home/

- name: Install elasticsearch
  apt:
    deb: /home/elasticsearch-8.6.2-amd64.deb

- name: Copy config file for elasticsearch
  copy:
    src: ../templates/elasticsearch.yml
    dest: /etc/elasticsearch
    mode: 0660
    owner: root
    group: elasticsearch

- name: Systemctl daemon reload
  systemd:
    daemon_reload: yes
    name: elasticsearch.service
    state: started

- name: Systemctl enable elasticsearch
  systemd:
    name: elasticsearch.service
    state: restarted
```

`nano 04_elasticsearch_playbook.yml`

```
---
- hosts: logs
  gather_facts: true
  become: true
  become_method: sudo
  become_user: root
  roles:
    - elasticsearch
    - node_exporter
```

`ansible-playbook 04_elasticsearch_playbook.yml`


##### С помощью `ansible-galaxy` инициализирую роль `kibana`

`ansible-galaxy init kibana`

`nano kibana/tasks/main.yml`

```
- name: Update apt cache
  apt:
    update_cache: yes
    
- name: Ensure dependencies are installed.
  apt:
    name:
      - apt-transport-https
      - gnupg2
    state: present

- name: Get kibana.8.6.2
  ansible.builtin.get_url:  
    url: https://mirror.yandex.ru/mirrors/elastic/8/pool/main/k/kibana/kibana-8.6.2-amd64.deb
    dest: /home/user/

- name: Install kibana
  apt:
    deb: /home/user/kibana-8.6.2-amd64.deb 

- name: Systemctl daemon reload
  systemd:
    daemon_reload: true
    name: kibana.service
    state: started

- name: Copy config file for kibana
  template:
    src: ./files/kibana.yml.j2
    dest: /etc/kibana/kibana.yml
    owner: root
    group: root
    mode: 0644

- name: Systemctl enable  kibana
  systemd:
    name: kibana.service
    state: restarted
```

`nano 05_kibana_playbook.yml`

```
- name: Play kibana
  hosts: logs
  become: yes
  roles:
  - kibana
  - node_exporter
```

`ansible-playbook 05_kibana_playbook.yml`

`ansible-galaxy init filebeat`

`nano filebeat/tasks/main.yml`

```
---
- name: Update apt cache
  apt:
    update_cache: yes

- name: Get filebeat
  ansible.builtin.get_url:
    url: https://mirror.yandex.ru/mirrors/elastic/8/pool/main/f/filebeat/filebeat-8.6.2-amd64.deb
    dest: /home/mikhail/

- name: Install filebeat
  apt:
    deb: /home/user/filebeat-8.6.2-amd64.deb 

- name: Copy config file for filebeat
  template:
    src: ../templates/filebeat.yml.j2
    dest: /etc/filebeat/filebeat.yml
    mode: 0600
    owner: root
    group: root


- name: Systemctl daemon reload
  systemd:
    daemon_reload: true
    name: filebeat.service
    state: started

- name: restarted nginx
  service:
    name: nginx
    state: restarted

- name: restarted filebeat
  systemd:
    name: filebeat.service
    state: restarted

- name: Enable filebeat.service, and not touch the state
  ansible.builtin.service:
    name: filebeat.service
    enabled: yes
```

## СЕТЬ

`nano bastion1.tf`

```
resource "yandex_compute_instance" "bastion-b" {
  name                      = "bastion1"
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
      description = "boot disk for private_bastion1"
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

resource "yandex_vpc_network" "network-c" {
  name = "network2"
}

resource "yandex_vpc_subnet" "subnet-c" {
  name           = "subnet3"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.30.0/24"]
  network_id     = "${yandex_vpc_network.network-c.id}"
}
```

`terraform validate`

`terraform plan`

`terraform apply`

## РЕЗЕРВНОЕ КОПИРОВАНИЕ

`nano snapshot.tf`

```
resource "yandex_compute_snapshot_schedule" "snapshot" {
  name = "snapshot"

  schedule_policy {
    expression = "0 0 ? * *"
  }

  snapshot_count = 7

  snapshot_spec {
    description = "daily"
  }

  disk_ids = [yandex_compute_instance.website-a.boot_disk.0.disk_id, yandex_compute_instance.website-b.boot_disk.0.disk_id, 
yandex_compute_instance.bastion-b.boot_disk.0.disk_id, 
yandex_compute_instance.zabbix-1.boot_disk.0.disk_id, 
yandex_compute_instance.elasticsearch-1.boot_disk.0.disk_id, 
yandex_compute_instance.kibana-1.boot_disk.0.disk_id]
}
```

`terraform validate`

`terraform plan`

`terraform apply`

