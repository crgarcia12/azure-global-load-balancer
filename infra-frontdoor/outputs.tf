output "aks_names" {
  value = [
    { resource_group_name = module.spoke_weu_s1.resource_group_name, aks_name = module.spoke_weu_s1.aks_name },
  ]
}