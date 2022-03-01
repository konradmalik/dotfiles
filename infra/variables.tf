variable "ocpus" {
  description = "The number of OCPUs to assign to the instance. Must be between 1 and 4."
  type        = number
  default     = 4

  validation {
    condition     = var.ocpus >= 1
    error_message = "The value of ocpus must be greater than or equal to 1."
  }

  validation {
    condition     = var.ocpus <= 4
    error_message = "The value of ocpus must be less than or equal to 4 to remain in the free tier."
  }
}

variable "memory_in_gbs" {
  description = "The amount of memory in GB to assign to the instance. Must be between 1 and 24."
  default     = 24

  validation {
    condition     = var.memory_in_gbs >= 1
    error_message = "The value of memory_in_gbs must be greater than or equal to 1."
  }

  validation {
    condition     = var.memory_in_gbs <= 24
    error_message = "The value of memory_in_gbs must be less than or equal to 24 to remain in the free tier."
  }
}

variable "boot_volume_size_in_gbs" {
  description = "A custom size for the boot volume. Must be between 50 and 200. If not set, defaults to the size of the image which is around 46 GB."
  default     = 200

  validation {
    condition     = var.boot_volume_size_in_gbs == null ? true : var.boot_volume_size_in_gbs >= 50
    error_message = "The value of boot_volume_size_in_gbs must be greater than or equal to 50."
  }

  validation {
    condition     = var.boot_volume_size_in_gbs == null ? true : var.boot_volume_size_in_gbs <= 200
    error_message = "The value of boot_volume_size_in_gbs must be less than or equal to 200 to remain in the free tier."
  }
}

variable "hostname" {
  description = "The hostname of the instance."
  type        = string
}

variable "compartment_id" {
  description = "The OCID of the compartment containing the instance."
  type        = string
}

variable "availability_domain" {
  description = "The availability domain of the instance."
  type        = string
}

variable "operating_system" {
  description = "The Operating System of the platform image to use. Valid values are \"Canonical Ubuntu\", \"Oracle Linux\", or \"Oracle Linux Cloud Developer\"."
  type        = string

  validation {
    condition     = contains(["Canonical Ubuntu", "Oracle Linux", "Oracle Linux Cloud Developer"], var.operating_system)
    error_message = "The value of operating_system must be one of \"Canonical Ubuntu\", \"Oracle Linux\", or \"Oracle Linux Cloud Developer\"."
  }
}

variable "operating_system_version" {
  description = "The version of the Operating System specified in `operating_system`."
  type        = string
}

variable "subnet_id" {
  description = "The OCID of the subnet to create the VNIC in."
  type        = string
}

variable "ssh_authorized_keys" {
  description = "The public SSH key(s) that should be authorized for the default user."
  type        = string
}

variable "user_data" {
  description = "User data passed to cloud-init when the instance is started. Defaults to `null`."
  type        = string
  default     = null
}

variable "assign_public_ip" {
  description = "Whether or not a public IP should be assigned to the instance.  Defaults to `null` which assigns a public IP based on whether the subnet is public or private. The Free Tier only includes 2 public IP addresses so you may need to set this to `false`."
  type        = bool
  default     = null
}

variable "assign_ipv6_address" {
  description = "Whether or not an IPv6 address should be assigned to the instance. Requires a subnet with IPv6 enabled. Defaults to `false`."
  type        = bool
  default     = false
}

variable "nsg_ids" {
  description = "A list of Network Security Group OCIDs to attach to the primary vnic."
  type        = list(string)
  default     = []
}
