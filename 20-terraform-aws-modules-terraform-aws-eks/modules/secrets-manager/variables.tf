# =============================================================================
# Secrets Manager Module - Variables
# =============================================================================

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string

  validation {
    condition     = length(var.name_prefix) > 0 && length(var.name_prefix) <= 40
    error_message = "name_prefix must be between 1 and 40 characters."
  }
}

variable "recovery_window_in_days" {
  description = "Number of days AWS waits before permanently deleting a secret or KMS key"
  type        = number
  default     = 7

  validation {
    condition     = var.recovery_window_in_days >= 7 && var.recovery_window_in_days <= 30
    error_message = "recovery_window_in_days must be between 7 and 30."
  }
}

# -----------------------------------------------------------------------------
# Database credentials
# -----------------------------------------------------------------------------

variable "create_db_secret" {
  description = "Create database credentials secret"
  type        = bool
  default     = false
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = ""
  sensitive   = true
}

variable "db_password" {
  description = "Database password. Leave empty to auto-generate a strong random password."
  type        = string
  default     = ""
  sensitive   = true
}

variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql", "mariadb", "oracle", "sqlserver"], var.db_engine)
    error_message = "db_engine must be one of: postgres, mysql, mariadb, oracle, sqlserver."
  }
}

variable "db_host" {
  description = "Database host"
  type        = string
  default     = ""
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# API keys
# -----------------------------------------------------------------------------

variable "create_api_secret" {
  description = "Create API keys secret"
  type        = bool
  default     = false
}

variable "api_key" {
  description = "API key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "api_secret" {
  description = "API secret"
  type        = string
  default     = ""
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Application config
# -----------------------------------------------------------------------------

variable "create_app_config_secret" {
  description = "Create application config secret"
  type        = bool
  default     = false
}

variable "app_config" {
  description = "Application configuration as a map"
  type        = map(string)
  default     = {}
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Common
# -----------------------------------------------------------------------------

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}