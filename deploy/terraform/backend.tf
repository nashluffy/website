terraform {
  backend "gcs" {
    bucket  = "nashluffy-website"
    prefix  = "terraform/"
  }
}
