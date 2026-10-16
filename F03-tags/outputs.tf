output "all_tags" {
  description = "Complete map of all tags (mandatory + conditional + automation + additional)."
  value       = local.all_tags
}

output "application" {
  description = "Application name."
  value       = var.application
}

output "archetype" {
  description = "Landing Zone archetype (if specified)."
  value       = var.archetype
}

output "cost_center" {
  description = "Cost center code."
  value       = var.cost_center
}

output "cost_tags" {
  description = "Cost allocation and chargeback tags."
  value       = local.cost_tags
}

output "creation_date" {
  description = "Date when the tags module was evaluated."
  value       = local.creation_date
}

output "criticality" {
  description = "Criticality level."
  value       = var.criticality
}

output "criticality_description" {
  description = "Human-readable description of the criticality level."
  value       = local.criticality_descriptions[var.criticality]
}

output "data_classification" {
  description = "Data classification level."
  value       = var.data_classification
}

output "data_classification_description" {
  description = "Human-readable description of the data classification level."
  value       = local.data_classification_descriptions[var.data_classification]
}

output "department" {
  description = "Department name (if specified)."
  value       = var.department
}

output "environment" {
  description = "Full environment name."
  value       = var.environment
}

output "environment_short" {
  description = "Short environment code (3 characters) for naming conventions."
  value       = local.environment_short
}

output "expiration_date" {
  description = "Expiration date for the resource (if set, especially for Sandbox)."
  value       = local.effective_expiration_date
}

output "has_expiration" {
  description = "Boolean indicating if an expiration date is set."
  value       = local.effective_expiration_date != null
}

output "is_critical" {
  description = "Boolean indicating if this is a critical or high-priority workload."
  value       = local.is_critical
}

output "is_production" {
  description = "Boolean indicating if this is a production-like environment (Production, PreProduction, DR)."
  value       = local.is_production
}

output "is_sandbox" {
  description = "Boolean indicating if this is a Sandbox environment."
  value       = local.is_sandbox
}

output "is_sensitive" {
  description = "Boolean indicating if this contains sensitive data (Confidential or Restricted)."
  value       = local.is_sensitive
}

output "mandatory_tags" {
  description = "Map of mandatory tags only (Environment, Owner, CostCenter, Application, Criticality, DataClassification, ManagedBy)."
  value       = local.mandatory_tags
}

output "operational_tags" {
  description = "Operational tags for monitoring and maintenance."
  value       = local.operational_tags
}

output "owner" {
  description = "Resource owner email."
  value       = var.owner
}

output "project" {
  description = "Project name (if specified)."
  value       = var.project
}

output "recommended_backup_tier" {
  description = "Recommended backup storage tier based on environment and criticality (GRS or LRS)."
  value       = local.backup_tier
}

output "recommended_retention_tier" {
  description = "Recommended retention tier based on criticality (long, standard, minimal)."
  value       = local.retention_tier
}

output "security_tags" {
  description = "Security-related tags for compliance and audit purposes."
  value       = local.security_tags
}

