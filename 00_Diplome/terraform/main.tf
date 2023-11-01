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
