variable "region" { default = "eu-west-1" }

variable "bucket" { default = {} }
variable "logbucket" {}

variable "blockPubAcl" { default = true }
variable "blockPubPol" { default = true }
variable "ignorePubAcl" { default = true }
variable "restrictPub" { default = true }