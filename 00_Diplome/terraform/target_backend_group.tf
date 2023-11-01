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
