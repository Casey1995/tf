provider "aws" {
  profile = var.profile
  region  = var.useast1
  alias   = "useast1"
}

provider "aws" {
  profile = var.profile
  region  = var.uswest2
  alias   = "uswest2"
}

