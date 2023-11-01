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


























```

```
