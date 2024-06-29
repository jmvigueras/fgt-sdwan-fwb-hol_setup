#-----------------------------------------------------------------------------------------------------
# Create new Route53 record - VPN DDNS - EMEA HUB
#-----------------------------------------------------------------------------------------------------
# Read Route53 Zone info
data "aws_route53_zone" "route53_zone" {
  name         = "${var.route53_zone_name}."
  private_zone = false
}
# Create a health-check and FGT records
resource "aws_route53_health_check" "hub_1_vpn_fqdn_hcks" {
  for_each = local.hub_1_public_eips

  ip_address        = each.value
  port              = var.admin_port
  type              = "TCP"
  failure_threshold = "5"
  request_interval  = "30"

  tags = merge(
    var.tags,
    { Name = "${var.prefix}-hub-1-hck-${replace(each.key, ".", "")}" }
  )
}
# Create Route53 record entry with FGT HUBs public IPs
resource "aws_route53_record" "hub_1_vpn_fqdn_fgts" {
  for_each = local.hub_1_public_eips

  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = "${replace(each.key, ".", "")}.hub-1.${var.route53_zone_name}"
  type    = "A"
  ttl     = "300"
  records = [each.value]
}
# Health-check parent
resource "aws_route53_health_check" "hub_1_vpn_fqdn_hck_parent" {
  type                   = "CALCULATED"
  child_health_threshold = 1
  child_healthchecks     = [for v in aws_route53_health_check.hub_1_vpn_fqdn_hcks : v.id]

  tags = merge(
    var.tags,
    { Name = "${var.prefix}-hub-1-hck-parent" }
  )
}
# Create Route53 record entry for VPN HUB
resource "aws_route53_record" "hub_1_vpn_fqdn" {
  for_each = local.hub_1_public_eips

  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = local.hub_1_vpn_ddns
  type    = "CNAME"
  ttl     = "300"

  weighted_routing_policy {
    weight = floor(100 / length(keys(local.hub_1_public_eips)))
  }

  set_identifier = replace(each.key, ".", "")
  records        = [aws_route53_record.hub_1_vpn_fqdn_fgts[each.key].name]

  health_check_id = aws_route53_health_check.hub_1_vpn_fqdn_hck_parent.id
}

#-----------------------------------------------------------------------------------------------------
# Create new Route53 record - VPN DDNS - EMEA OP
#-----------------------------------------------------------------------------------------------------
# Create a health-check and FGT records
resource "aws_route53_health_check" "hub_2_vpn_fqdn_hcks" {
  for_each = local.hub_2_public_eips

  ip_address        = each.value
  port              = var.admin_port
  type              = "TCP"
  failure_threshold = "5"
  request_interval  = "30"

  tags = merge(
    var.tags,
    { Name = "${var.prefix}-hub-2-hck-${replace(each.key, ".", "")}" }
  )
}
# Create Route53 record entry with FGT HUBs public IPs
resource "aws_route53_record" "hub_2_vpn_fqdn_fgts" {
  for_each = local.hub_2_public_eips

  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = "${replace(each.key, ".", "")}.hub-2.${var.route53_zone_name}"
  type    = "A"
  ttl     = "300"
  records = [each.value]
}
# Health-check parent
resource "aws_route53_health_check" "hub_2_vpn_fqdn_hck_parent" {
  type                   = "CALCULATED"
  child_health_threshold = 1
  child_healthchecks     = [for v in aws_route53_health_check.hub_2_vpn_fqdn_hcks : v.id]

  tags = merge(
    var.tags,
    { Name = "${var.prefix}-hub-2-hck-parent" }
  )
}
# Create Route53 record entry for VPN HUB
resource "aws_route53_record" "hub_2_vpn_fqdn" {
  for_each = local.hub_2_public_eips

  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = local.hub_2_vpn_ddns
  type    = "CNAME"
  ttl     = "300"

  weighted_routing_policy {
    weight = floor(100 / length(local.hub_2_public_eips))
  }

  set_identifier = replace(each.key, ".", "")
  records        = [aws_route53_record.hub_2_vpn_fqdn_fgts[each.key].name]

  health_check_id = aws_route53_health_check.hub_2_vpn_fqdn_hck_parent.id
}
# Create Route53 record entry with FGT HUBs public IPs
resource "aws_route53_record" "hub_1_fmail_record" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = "fmail.${var.route53_zone_name}"
  type    = "A"
  ttl     = "300"
  records = [for ip in local.hub_1_public_eips : ip]
}
# Create Route53 record entry with FGT HUBs public IPs
resource "aws_route53_record" "hub_1_server_record" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = "server.${var.route53_zone_name}"
  type    = "A"
  ttl     = "300"
  records = [for ip in local.hub_1_public_eips : ip]
}