/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


resource "google_iam_workload_identity_pool" "github" {
  depends_on = [
    google_project_service.gcp_services
  ]

  project                   = local.project_id
  workload_identity_pool_id = "github-actions"
  display_name              = "GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github-provider" {
  depends_on = [
    google_project_service.gcp_services
  ]

  project                            = local.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "github-provider"
  description                        = "OIDC identity pool provider for automated test"
  attribute_condition                = "assertion.repository=='${local.github_repo}'"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

output "workload_identity_pool_provider_id" {
  value = google_iam_workload_identity_pool_provider.github-provider.name
}


resource "google_service_account" "github-wif" {
  depends_on = [
    google_project_service.gcp_services
  ]

  project    = var.project_id
  account_id = "github-wif"
}

output "workload_identity_pool_sa" {
  value = google_service_account.github-wif.email
}

resource "google_service_account_iam_binding" "iam-workloadIdentityUser" {
  service_account_id = google_service_account.github-wif.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/projects/${local.project_number}/locations/global/workloadIdentityPools/github-actions/attribute.repository/${local.github_repo}"
  ]

  depends_on = [
    google_service_account.github-wif,
    google_iam_workload_identity_pool.github
  ]
}

resource "google_project_iam_custom_role" "github_custom_permissions" {
  depends_on = [
    google_service_account.github-wif
  ]

  role_id     = "github_actions_role"  # Choose a unique role ID
  project = var.project_id
  title       = "Github actions Custom Role"
  permissions = [
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.getIamPolicy",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy"
  ]
}

resource "google_project_iam_binding" "github_custom_role" {
  depends_on = [
    google_service_account.github-wif
  ]

  project = local.project_id
  role    = "projects/${local.project_id}/roles/${google_project_iam_custom_role.github_custom_permissions.role_id}"
  members = ["serviceAccount:${google_service_account.github-wif.email}"]
}

resource "google_project_iam_member" "github_serviceUsageAdmin" {
  depends_on = [
    google_project_service.gcp_services
  ]

  project = local.project_id
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:${google_service_account.github-wif.email}"
}

resource "google_project_iam_member" "github_storageAdmin" {
  depends_on = [
    google_project_service.gcp_services
  ]

  project = local.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.github-wif.email}"
}

resource "google_project_iam_member" "github_workloadIdentityPoolAdmin" {
  depends_on = [
    google_project_service.gcp_services
  ]

  project = local.project_id
  role    = "roles/iam.workloadIdentityPoolAdmin"
  member  = "serviceAccount:${google_service_account.github-wif.email}"
}
