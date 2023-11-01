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
