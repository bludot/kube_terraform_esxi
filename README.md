# Kubernetes deployment on ESXI


get cloud image here: http://backup.floretos.com:9000/images/focal-server-cloudimg-amd64.ova

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_template"></a> [template](#requirement\_template) | 2.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_esxi"></a> [esxi](#provider\_esxi) | 1.10.3 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| esxi_guest.master | resource |
| esxi_guest.node | resource |
| esxi_virtual_disk.master_disk | resource |
| esxi_virtual_disk.node_disks | resource |
| [template_file.master_metadata](https://registry.terraform.io/providers/hashicorp/template/2.2.0/docs/data-sources/file) | data source |
| [template_file.master_userdata](https://registry.terraform.io/providers/hashicorp/template/2.2.0/docs/data-sources/file) | data source |
| [template_file.node_metadata](https://registry.terraform.io/providers/hashicorp/template/2.2.0/docs/data-sources/file) | data source |
| [template_file.node_userdata](https://registry.terraform.io/providers/hashicorp/template/2.2.0/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_esxi_host"></a> [esxi\_host](#input\_esxi\_host) | n/a | `string` | n/a | yes |
| <a name="input_esxi_password"></a> [esxi\_password](#input\_esxi\_password) | n/a | `string` | n/a | yes |
| <a name="input_esxi_user"></a> [esxi\_user](#input\_esxi\_user) | n/a | `string` | n/a | yes |
| <a name="input_gateway_ip"></a> [gateway\_ip](#input\_gateway\_ip) | n/a | `string` | n/a | yes |
| <a name="input_guest_name"></a> [guest\_name](#input\_guest\_name) | n/a | `string` | `"kube-infra"` | no |
| <a name="input_master_boot_disk_size"></a> [master\_boot\_disk\_size](#input\_master\_boot\_disk\_size) | n/a | `number` | n/a | yes |
| <a name="input_master_disk_size"></a> [master\_disk\_size](#input\_master\_disk\_size) | n/a | `number` | n/a | yes |
| <a name="input_master_ip"></a> [master\_ip](#input\_master\_ip) | n/a | `string` | n/a | yes |
| <a name="input_node_boot_disk_size"></a> [node\_boot\_disk\_size](#input\_node\_boot\_disk\_size) | n/a | `number` | n/a | yes |
| <a name="input_node_disk_size"></a> [node\_disk\_size](#input\_node\_disk\_size) | n/a | `number` | n/a | yes |
| <a name="input_node_ips"></a> [node\_ips](#input\_node\_ips) | n/a | `list(string)` | n/a | yes |
| <a name="input_ssh_key_priv"></a> [ssh\_key\_priv](#input\_ssh\_key\_priv) | n/a | `string` | n/a | yes |
| <a name="input_ssh_key_pub"></a> [ssh\_key\_pub](#input\_ssh\_key\_pub) | n/a | `string` | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | n/a | `string` | `"ubuntu"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud-init"></a> [cloud-init](#output\_cloud-init) | n/a |
<!-- END_TF_DOCS -->
