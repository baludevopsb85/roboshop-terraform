# ----------------------------------
# Local Variables for Naming and DNS
# ----------------------------------
#tagName → EC2/other resource tag name (includes environment if provided).
#dnsName → Internal DNS name for private access.
#dnsNamePublic → Public DNS name for external access.

locals {
  tagName       = var.env == null ? var.name : "${var.name}-${var.env}"
  dnsName       = var.env == null ? "${var.name}-internal" : "${var.name}-${var.env}"
  dnsNamePublic = var.env == null ? var.name : "${var.name}-${var.env}"
}
