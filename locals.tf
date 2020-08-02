locals {
  aliases = concat(
    [var.root_domain],
    var.subdomains,
  )
  allowlist_ip = concat(
    var.allowlist_ipv4,
    var.allowlist_ipv6,
  )
}
