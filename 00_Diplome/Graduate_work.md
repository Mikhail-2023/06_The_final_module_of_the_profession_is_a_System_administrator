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





















```

```
