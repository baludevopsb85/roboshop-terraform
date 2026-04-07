locals {
  subnet_peering_combination = {
    for pair in flatten([
      for subnet_key, subnet_val in aws_subnet.main : [
        for peer_key, peer_val in aws_vpc_peering_connection.main : {
          key = "${subnet_key}-${peer_key}"
          value = {
            subnet_id  = subnet_val.id
            peering_id = peer_val.id
          }
        }
      ]
    ]) :
    pair.key => pair.value
  }

  route_peering_combination = {
    for pair in flatten([
      for route_key, route_val in aws_route_table.main : [
        for peer_key, peer_val in aws_vpc_peering_connection.main : {
          key = "${route_key}-${peer_key}"
          value = {
            route_table_id = route_val.id
            peering_id     = peer_val.id
            vpc_id         = peer_val.vpc_id
          }
        }
      ]
    ]) :
    pair.key => pair.value
  }

  ngw_subnets = {
    for name, subnet in var.subnets :
    name => subnet
    if try(subnet.ngw, false) == true
  }

  igw_subnets = {
    for name, subnet in var.subnets :
    name => subnet
    if try(subnet.igw, false) == true
  }

}
