resource "yandex_compute_snapshot_schedule" "snapshot" {
  name = "snapshot"

  schedule_policy {
    expression = "0 0 ? * *"
  }

  snapshot_count = 7

  snapshot_spec {
    description = "daily"
  }

  disk_ids = [yandex_compute_instance.website-a.boot_disk.0.disk_id, 
yandex_compute_instance.website-b.boot_disk.0.disk_id, 
yandex_compute_instance.bastion-b.boot_disk.0.disk_id, 
yandex_compute_instance.zabbix-1.boot_disk.0.disk_id, 
yandex_compute_instance.elasticsearch-1.boot_disk.0.disk_id, 
yandex_compute_instance.kibana-1.boot_disk.0.disk_id]
}
