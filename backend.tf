terraform {
  cloud {
    organization = "justfrt"
    workspaces {
      name = "lab"
    }
  }
}