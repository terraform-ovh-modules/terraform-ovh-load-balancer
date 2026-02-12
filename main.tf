# ========================================
# Locals for Computed Values
# ========================================

locals {
  # Merge user tags with default tags
  final_tags = merge(
    {
      managed_by = "terraform"
      module     = "terraform-ovh-load-balancer"
    },
    var.tags
  )

  # Convert tags to OpenStack format (list of "key=value" strings)
  openstack_tags = [for k, v in local.final_tags : "${k}=${v}"]

  # Create a map of listener names to listener resources
  listener_map = {
    for listener in openstack_lb_listener_v2.listeners :
    listener.name => listener
  }

  # Create a map of pool names to pool resources
  pool_map = {
    for pool in openstack_lb_pool_v2.pools :
    pool.name => pool
  }
}

# ========================================
# Load Balancer
# ========================================

resource "openstack_lb_loadbalancer_v2" "loadbalancer" {
  name           = var.name
  description    = var.description
  region         = var.region
  vip_subnet_id  = var.vip_subnet_id
  vip_address    = var.vip_address != "" ? var.vip_address : null
  admin_state_up = var.admin_state_up

  tags = local.openstack_tags
}

# ========================================
# Listeners
# ========================================

resource "openstack_lb_listener_v2" "listeners" {
  for_each = { for listener in var.listeners : listener.name => listener }

  name            = each.value.name
  protocol        = each.value.protocol
  protocol_port   = each.value.protocol_port
  loadbalancer_id = openstack_lb_loadbalancer_v2.loadbalancer.id
  admin_state_up  = var.admin_state_up

  connection_limit        = each.value.connection_limit
  timeout_client_data     = each.value.timeout_client_data
  timeout_member_connect  = each.value.timeout_member_connect
  timeout_member_data     = each.value.timeout_member_data
  timeout_tcp_inspect     = each.value.timeout_tcp_inspect

  tags = local.openstack_tags

  depends_on = [openstack_lb_loadbalancer_v2.loadbalancer]
}

# ========================================
# Pools
# ========================================

resource "openstack_lb_pool_v2" "pools" {
  for_each = { for pool in var.pools : pool.name => pool }

  name        = each.value.name
  protocol    = each.value.protocol
  lb_method   = each.value.lb_method
  region      = var.region
  listener_id = each.value.listener_name != null ? local.listener_map[each.value.listener_name].id : null

  dynamic "session_persistence" {
    for_each = each.value.session_persistence != null ? [each.value.session_persistence] : []
    content {
      type        = session_persistence.value.type
      cookie_name = session_persistence.value.cookie_name
    }
  }

  depends_on = [openstack_lb_listener_v2.listeners]
}

# ========================================
# Pool Members
# ========================================

resource "openstack_lb_member_v2" "members" {
  for_each = { for idx, member in var.members : "${member.pool_name}-${idx}" => member }

  pool_id       = local.pool_map[each.value.pool_name].id
  address       = each.value.address
  protocol_port = each.value.protocol_port
  weight        = each.value.weight
  backup        = each.value.backup
  subnet_id     = each.value.subnet_id != null ? each.value.subnet_id : var.vip_subnet_id

  depends_on = [openstack_lb_pool_v2.pools]
}

# ========================================
# Health Monitors
# ========================================

resource "openstack_lb_monitor_v2" "monitors" {
  for_each = { for monitor in var.health_monitors : monitor.pool_name => monitor }

  pool_id        = local.pool_map[each.value.pool_name].id
  type           = each.value.type
  delay          = each.value.delay
  timeout        = each.value.timeout
  max_retries    = each.value.max_retries
  url_path       = each.value.url_path
  http_method    = each.value.http_method
  expected_codes = each.value.expected_codes

  depends_on = [openstack_lb_pool_v2.pools]
}
