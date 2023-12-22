terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.34.1"
    }
  }
}

variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_kubernetes_cluster" "management" {
  name   = "management"
  region = "nyc1"
  version = "1.27.6-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 3
  }
}

resource "digitalocean_container_registry" "gitops-demo" {
  name = "gitops-demo"
  subscription_tier_slug = "starter"
}

resource "digitalocean_container_registry_docker_credentials" "flux-creds" {
  registry_name = "gitops-demo"
}

provider "kubernetes" {
  host  = digitalocean_kubernetes_cluster.management.endpoint
  token = digitalocean_kubernetes_cluster.management.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.management.kube_config[0].cluster_ca_certificate
  )
}

resource "kubernetes_secret" "gitops-demo-creds" {
  metadata {
    name = "docker-cfg"
  }

  data = {
    ".dockerconfigjson" = digitalocean_container_registry_docker_credentials.flux-creds.docker_credentials
  }

  type = "kubernetes.io/dockerconfigjson"
}

