terraform {
  source = "../../../modules//ec2_instance"
}

include "root" {
  path = find_in_parent_folders()
}
