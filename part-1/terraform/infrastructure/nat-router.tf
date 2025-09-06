data "google_compute_network" "default" {
  name = "default"
}

resource "google_compute_router" "nat-router" {
  name    = "nat-router"
  network = data.google_compute_network.default.id
  region  = var.google_region
}

resource "google_compute_router_nat" "main" {
  name                               = "cloud-nat"
  region                             = google_compute_router.nat-router.region
  router                             = google_compute_router.nat-router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
