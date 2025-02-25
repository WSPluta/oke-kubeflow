# Gets VCN ID
data "oci_core_vcn" "vcn_info" {
  vcn_id = var.useExistingVcn ? var.myVcn : module.network.vcn-id
}

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}


locals {
  # Helm repos
  helm_repository = {
    stable        = "https://kubernetes-charts.storage.googleapis.com"
    ingress-nginx = "https://kubernetes.github.io/ingress-nginx"
    jetstack      = "https://charts.jetstack.io"                        # cert-manager
    svc-cat       = "https://svc-catalog-charts.storage.googleapis.com" # Service Catalog
  }
}

# OCI Services
## Available Services
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

## Object Storage
data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_ocid
}

# Randoms
resource "random_string" "deploy_id" {
  length  = 4
  special = false
}

# Image lookup
data "oci_core_images" "oraclelinux7" {
  compartment_id           = var.compartment_ocid
  shape                    = var.instance_shape
  operating_system         = "Oracle Linux"
  operating_system_version = 8
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
#   shape                  = var.image_shape
#   state                  = var.image_state
}

# data "oci_core_images" "all_images" {
#   compartment_id = var.compartment_ocid
#   operating_system = "Oracle Linux"
#   operating_system_version = "7.9"
#   # Add other filters or parameters as needed
# }

locals {
  bastion_subnet = var.public_edge_node ? module.network.edge-id : module.network.private-id
  is_oke_public = var.cluster_endpoint_config_is_public_ip_enabled ? module.network.edge-id : module.network.private-id
#   latest_oraclelinux7_image_id = data.oci_core_images.oraclelinux7.images[0].id
}

data "oci_containerengine_cluster_option" "latestclusterversion" {
    #Required
    cluster_option_id = "all"
}



