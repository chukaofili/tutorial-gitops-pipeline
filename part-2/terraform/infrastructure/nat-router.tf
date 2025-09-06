############################################
# Added for Part 2
############################################

############################################
# 1) Create a Cloud Router
############################################
# A Cloud Router is required for Cloud NAT.
# It manages dynamic routes and acts as the control plane for NAT.
resource "google_compute_router" "nat-router" {
  # Name for the router resource
  name = "nat-router"

  # Attach the router to the default VPC
  network = data.google_compute_network.default.id

  # Region where the router (and NAT) will live.
  # Should match the region of your GKE nodes.
  region = var.google_region
}

############################################
# 2) Configure Cloud NAT
############################################
# Cloud NAT lets private resources (like GKE nodes without public IPs)
# access the internet securely for pulling container images, updates, etc.
resource "google_compute_router_nat" "main" {
  # Name for the NAT configuration
  name = "cloud-nat"

  # Region and router this NAT belongs to
  region = google_compute_router.nat-router.region
  router = google_compute_router.nat-router.name

  # AUTO_ONLY means Google will assign ephemeral external IPs for NAT.
  # You can switch to MANUAL if you want to reserve and manage static IPs.
  nat_ip_allocate_option = "AUTO_ONLY"

  # Apply NAT to all subnets and all IP ranges in this region.
  # This ensures every private GKE node in the VPC can reach the internet.
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
