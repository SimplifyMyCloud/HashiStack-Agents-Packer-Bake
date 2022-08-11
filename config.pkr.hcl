packer {
  required_plugins {
    googlecompute = {
      version = ">= 1.0.13"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}