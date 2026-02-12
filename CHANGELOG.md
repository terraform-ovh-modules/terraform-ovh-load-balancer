# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-02-12

### Added
- Initial release of OVH load balancer module
- Support for creating load balancers on OVH Public Cloud
- Multiple listener support with configurable protocols (TCP, HTTP, HTTPS, TERMINATED_HTTPS, UDP)
- Pool configuration with multiple load balancing methods (ROUND_ROBIN, LEAST_CONNECTIONS, SOURCE_IP)
- Backend member management with weight and backup configuration
- Health monitor support for automatic failover
- Session persistence configuration
- VIP address management (automatic or manual assignment)
- Comprehensive input validation for regions and configurations
- Detailed outputs for integration with other modules
- Simple and complete usage examples
- GitHub Actions CI/CD workflows for validation

### Features
- Load balancer creation with OpenStack provider
- Support for multiple listeners per load balancer
- Flexible pool configuration with session persistence
- Health monitoring with TCP, HTTP, HTTPS, PING, and UDP-CONNECT support
- Backend member management with weight-based distribution
- Support for all OVH regions (GRA, SBG, BHS, DE, UK, WAW)
- Resource tagging for organization and billing
- VIP subnet and address configuration
- Admin state control for load balancer and listeners
- Connection timeout configuration for listeners
- Circular dependency prevention between load balancer components

[Unreleased]: https://github.com/terraform-ovh-modules/terraform-ovh-load-balancer/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/terraform-ovh-modules/terraform-ovh-load-balancer/releases/tag/v1.0.0
