variable "creds_path" {
    default = "../credentials.json"
} 

variable "project" {
    default = "dark-depth-298212"
} 

variable "region" {
    default = "asia-southeast2"
} 

variable "zone" {
    default = "asia-southeast2-a"
} 

variable "image" {
    default = "ubuntu-os-cloud/ubuntu-1804-lts"
} 

variable "size" {
    default = "f1-micro"
} 

variable "net" {
    default = "default"
} 

variable "init" {
    default = "sudo apt-get update; sudo apt-get install -y python3-pip;"
}

variable "pub_sub_name" {
    default = "pstobq"
}

variable "bq_dataset" {
    default = "network"
}

variable "bq_table" {
    default = "packets"
}