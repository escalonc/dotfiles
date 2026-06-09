# Pins OpenTofu and the providers this config needs. `tofu init` reads this,
# downloads the hcloud provider, and records exact versions in
# .terraform.lock.hcl (commit that lock file — it makes installs reproducible).
terraform {
  required_version = ">= 1.6"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.48" # stay on 1.x; ~> floats patch/minor, never a major bump
    }
  }
}

# The provider talks to the Hetzner Cloud API and needs a token
# (Hetzner console → your project → Security → API Tokens → Read & Write).
# The value comes from a variable so it's never hard-coded here; see variables.tf.
provider "hcloud" {
  token = var.hcloud_token
}
