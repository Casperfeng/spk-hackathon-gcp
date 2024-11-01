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


resource "google_compute_global_address" "default" {
  project = local.project_id
  name    = "web-static-ip"
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  project               = local.project_id
  name                  = "http-lb-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}

# http proxy
resource "google_compute_target_http_proxy" "default" {
  project = local.project_id
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.default.id
}

# url map
resource "google_compute_url_map" "default" {
  project         = local.project_id
  name            = "http-lb"
  default_service = google_compute_backend_bucket.default.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "static"
  }

  path_matcher {
    name            = "static"
    default_service = google_compute_backend_bucket.default.id

    path_rule {
      paths   = ["/api"]
      service = google_compute_backend_service.run-backend-srv.id
    }
  }
}

# backend bucket with CDN policy with default ttl settings
resource "google_compute_backend_bucket" "default" {
  project     = local.project_id
  name        = "web-backend-bucket"
  bucket_name = google_storage_bucket.static_website_bucket.name
  enable_cdn  = true

  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    client_ttl        = 3600
    default_ttl       = 3600
    max_ttl           = 86400
    negative_caching  = true
    serve_while_stale = 86400
  }
}