variable "role_assignments" {
  description = "Role assignments to create"
  type = map(object({
    scope                = string
    role_definition_name = string
    principal_id         = string
  }))
  default = {}
}
