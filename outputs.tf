# ========================================
# Load Balancer Outputs
# ========================================

output "loadbalancer_id" {
  description = "The ID of the created load balancer. Use this to reference the load balancer in other resources."
  value       = openstack_lb_loadbalancer_v2.loadbalancer.id
}

output "loadbalancer_name" {
  description = "The name of the created load balancer"
  value       = openstack_lb_loadbalancer_v2.loadbalancer.name
}

output "loadbalancer_vip_address" {
  description = "The VIP address of the load balancer"
  value       = openstack_lb_loadbalancer_v2.loadbalancer.vip_address
}

output "loadbalancer_vip_port_id" {
  description = "The port ID of the VIP"
  value       = openstack_lb_loadbalancer_v2.loadbalancer.vip_port_id
}

output "loadbalancer_vip_subnet_id" {
  description = "The subnet ID where the VIP is located"
  value       = openstack_lb_loadbalancer_v2.loadbalancer.vip_subnet_id
}

output "loadbalancer_region" {
  description = "The region where the load balancer is deployed"
  value       = openstack_lb_loadbalancer_v2.loadbalancer.region
}

# ========================================
# Listener Outputs
# ========================================

output "listener_ids" {
  description = "Map of listener names to their IDs"
  value = {
    for name, listener in openstack_lb_listener_v2.listeners :
    name => listener.id
  }
}

output "listener_details" {
  description = "Complete details of all listeners"
  value = {
    for name, listener in openstack_lb_listener_v2.listeners :
    name => {
      id            = listener.id
      protocol      = listener.protocol
      protocol_port = listener.protocol_port
    }
  }
}

# ========================================
# Pool Outputs
# ========================================

output "pool_ids" {
  description = "Map of pool names to their IDs"
  value = {
    for name, pool in openstack_lb_pool_v2.pools :
    name => pool.id
  }
}

output "pool_details" {
  description = "Complete details of all pools"
  value = {
    for name, pool in openstack_lb_pool_v2.pools :
    name => {
      id        = pool.id
      protocol  = pool.protocol
      lb_method = pool.lb_method
    }
  }
}

# ========================================
# Member Outputs
# ========================================

output "member_ids" {
  description = "Map of member keys to their IDs"
  value = {
    for key, member in openstack_lb_member_v2.members :
    key => member.id
  }
}

output "member_details" {
  description = "Complete details of all pool members"
  value = {
    for key, member in openstack_lb_member_v2.members :
    key => {
      id            = member.id
      address       = member.address
      protocol_port = member.protocol_port
      weight        = member.weight
    }
  }
}

# ========================================
# Health Monitor Outputs
# ========================================

output "monitor_ids" {
  description = "Map of health monitor pool names to their IDs"
  value = {
    for name, monitor in openstack_lb_monitor_v2.monitors :
    name => monitor.id
  }
}

output "monitor_details" {
  description = "Complete details of all health monitors"
  value = {
    for name, monitor in openstack_lb_monitor_v2.monitors :
    name => {
      id          = monitor.id
      type        = monitor.type
      delay       = monitor.delay
      timeout     = monitor.timeout
      max_retries = monitor.max_retries
    }
  }
}

# ========================================
# Composite Outputs
# ========================================

output "loadbalancer_details" {
  description = "Complete details of the load balancer for use in other modules"
  value = {
    id            = openstack_lb_loadbalancer_v2.loadbalancer.id
    name          = openstack_lb_loadbalancer_v2.loadbalancer.name
    vip_address   = openstack_lb_loadbalancer_v2.loadbalancer.vip_address
    vip_port_id   = openstack_lb_loadbalancer_v2.loadbalancer.vip_port_id
    vip_subnet_id = openstack_lb_loadbalancer_v2.loadbalancer.vip_subnet_id
    region        = openstack_lb_loadbalancer_v2.loadbalancer.region
    listeners     = [for listener in openstack_lb_listener_v2.listeners : listener.id]
    pools         = [for pool in openstack_lb_pool_v2.pools : pool.id]
  }
}

output "connection_info" {
  description = "Connection information for accessing the load balancer"
  value = {
    vip_address = openstack_lb_loadbalancer_v2.loadbalancer.vip_address
    listeners = {
      for name, listener in openstack_lb_listener_v2.listeners :
      name => {
        protocol = listener.protocol
        port     = listener.protocol_port
        url      = "${lower(listener.protocol)}://${openstack_lb_loadbalancer_v2.loadbalancer.vip_address}:${listener.protocol_port}"
      }
    }
  }
}
