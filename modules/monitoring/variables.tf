variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "create_action_group" {
  description = "Create action group"
  type        = bool
  default     = false
}

variable "action_group_name" {
  description = "Action group name"
  type        = string
  default     = ""
}

variable "action_group_short_name" {
  description = "Action group short name"
  type        = string
  default     = ""
}

variable "email_receivers" {
  description = "Email receivers"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
