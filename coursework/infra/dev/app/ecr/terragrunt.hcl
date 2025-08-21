include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "module" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_env/app/ecr.hcl"
  expose = true
}