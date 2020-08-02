locals {
  aliases = concat(
    [var.root_domain],
    var.subdomains,
  )
}
