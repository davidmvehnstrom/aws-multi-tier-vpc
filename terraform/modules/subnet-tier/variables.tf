variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = map(object({
    cidr   = string
    az     = string
    pub_ip = bool
    name   = string
  }))
}

