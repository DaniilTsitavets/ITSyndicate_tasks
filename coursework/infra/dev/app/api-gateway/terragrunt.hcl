include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "module" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_env/app/api-gateway.hcl"
  expose = true
}