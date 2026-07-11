locals {
  nat_gateway_count = var.enable_nat_gateway ? (
    var.single_nat_gateway ? 1 : length(var.public_subnets)
  ) : 0
}