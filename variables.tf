# ========================================
# Required Variables
# ========================================

variable "name" {
  description = "Name of the load balancer"
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 255
    error_message = "Load balancer name must be between 1 and 255 characters."
  }
}

variable "region" {
  description = "OVH region where the load balancer will be created (e.g., GRA7, SBG5, BHS5)"
  type        = string

  validation {
    condition = contains([
      "GRA1", "GRA3", "GRA5", "GRA7", "GRA9", "GRA11",
      "SBG3", "SBG5", "SBG7",
      "BHS3", "BHS5",
      "DE1",
      "UK1",
      "WAW1"
    ], var.region)
    error_message = "Invalid OVH region specified. Supported regions: GRA*, SBG*, BHS*, DE1, UK1, WAW1."
  }
}

variable "vip_subnet_id" {
  description = "ID of the subnet where the load balancer VIP will be created"
  type        = string

  validation {
    condition     = length(var.vip_subnet_id) > 0
    error_message = "VIP subnet ID cannot be empty."
  }
}

# ========================================
# Optional Variables
# ========================================

variable "description" {
  description = "Description of the load balancer"
  type        = string
  default     = ""
}

variable "vip_address" {
  description = "Specific IP address for the VIP. If not specified, an IP will be automatically assigned from the subnet."
  type        = string
  default     = ""

  validation {
    condition     = var.vip_address == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.vip_address))
    error_message = "VIP address must be a valid IPv4 address."
  }
}

variable "admin_state_up" {
  description = "Administrative state of the load balancer. Set to false to disable the load balancer."
  type        = bool
  default     = true
}

# ========================================
# Listener Configuration
# ========================================

variable "listeners" {
  description = "List of listeners to create for the load balancer"
  type = list(object({
    name            = string
    protocol        = string
    protocol_port   = number
    connection_limit = optional(number)
    timeout_client_data = optional(number)
    timeout_member_connect = optional(number)
    timeout_member_data = optional(number)
    timeout_tcp_inspect = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for listener in var.listeners :
      contains(["TCP", "HTTP", "HTTPS", "TERMINATED_HTTPS", "UDP"], listener.protocol)
    ])
    error_message = "Listener protocol must be one of: TCP, HTTP, HTTPS, TERMINATED_HTTPS, UDP."
  }

  validation {
    condition = alltrue([
      for listener in var.listeners :
      listener.protocol_port > 0 && listener.protocol_port <= 65535
    ])
    error_message = "Listener protocol_port must be between 1 and 65535."
  }
}

# ========================================
# Pool Configuration
# ========================================

variable "pools" {
  description = "List of pools to create for the load balancer"
  type = list(object({
    name            = string
    protocol        = string
    lb_method       = string
    listener_name   = optional(string)
    session_persistence = optional(object({
      type        = string
      cookie_name = optional(string)
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for pool in var.pools :
      contains(["TCP", "HTTP", "HTTPS", "PROXY", "UDP"], pool.protocol)
    ])
    error_message = "Pool protocol must be one of: TCP, HTTP, HTTPS, PROXY, UDP."
  }

  validation {
    condition = alltrue([
      for pool in var.pools :
      contains(["ROUND_ROBIN", "LEAST_CONNECTIONS", "SOURCE_IP"], pool.lb_method)
    ])
    error_message = "Pool lb_method must be one of: ROUND_ROBIN, LEAST_CONNECTIONS, SOURCE_IP."
  }
}

# ========================================
# Member Configuration
# ========================================

variable "members" {
  description = "List of members (backend servers) to add to pools"
  type = list(object({
    pool_name     = string
    address       = string
    protocol_port = number
    weight        = optional(number, 1)
    backup        = optional(bool, false)
    subnet_id     = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for member in var.members :
      member.protocol_port > 0 && member.protocol_port <= 65535
    ])
    error_message = "Member protocol_port must be between 1 and 65535."
  }

  validation {
    condition = alltrue([
      for member in var.members :
      member.weight >= 0 && member.weight <= 256
    ])
    error_message = "Member weight must be between 0 and 256."
  }
}

# ========================================
# Health Monitor Configuration
# ========================================

variable "health_monitors" {
  description = "List of health monitors to create for pools"
  type = list(object({
    pool_name    = string
    type         = string
    delay        = number
    timeout      = number
    max_retries  = number
    url_path     = optional(string)
    http_method  = optional(string)
    expected_codes = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for monitor in var.health_monitors :
      contains(["TCP", "HTTP", "HTTPS", "PING", "UDP-CONNECT"], monitor.type)
    ])
    error_message = "Health monitor type must be one of: TCP, HTTP, HTTPS, PING, UDP-CONNECT."
  }

  validation {
    condition = alltrue([
      for monitor in var.health_monitors :
      monitor.delay > 0 && monitor.timeout > 0 && monitor.max_retries > 0
    ])
    error_message = "Health monitor delay, timeout, and max_retries must be positive numbers."
  }

  validation {
    condition = alltrue([
      for monitor in var.health_monitors :
      monitor.timeout < monitor.delay
    ])
    error_message = "Health monitor timeout must be less than delay."
  }
}

# ========================================
# Metadata and Tagging
# ========================================

variable "tags" {
  description = "Key-value tags to apply to the load balancer for organization and billing"
  type        = map(string)
  default     = {}
}
