variable ovh_region {
  type        = set(string)
  description = "OVHcloud Public Cloud region used"
  default     = ["GRA7","BHS5"]
}

variable bbb_fqdn {
  type        = string
  description = "BBB url"
}

variable bbb_secret {
  type        = string
  description = "BBB secret"
}

variable image {
  type        = string
  description = "BBB StressTest Server Linux distribution"
  default     = "Ubuntu 20.10"
}

variable flavor {
  type        = string
  description = "BBB StressTest Server Flavor"
  default     = "c2-30-flex"
}

variable nb_instances {
  type        = number
  description = "Number of StressTest server deployed per Openstack region"
  default     = 4
}

variable params {
  type = object({
    duration    = number
    listen_only = number
    micro       = number
    webcam      = number
  })
  default = {
    duration    = 600
    listen_only = 10
    micro       = 5
    webcam      = 1
  }
}

variable keypair_name {
  type        = string
  description = "Keypair name stored in Openstack"
  default     = "stresstest_keypair"
}

variable public_key {
  type        = string
  description = "Public Key stored in Openstack"
  default     = "~/.ssh/id_rsa.pub"
}
