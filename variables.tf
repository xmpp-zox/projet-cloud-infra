variable "project" {
  type    = string
  default = "proj-cloud"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "azs" {
  description = "Two AZs to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

# --- App ---
variable "backend_repo" {
  description = "Git URL of your backend fork (must expose GET /health)"
  type        = string
  default     = "https://github.com/alaabenhmida/backend.git"
}

variable "frontend_dist_repo" {
  description = "Git URL of the repo containing the Angular production build (dist/)"
  type        = string
  default     = "https://github.com/alaabenhmida/client.git"
}

variable "backend_port" {
  type    = number
  default = 3000
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "frontend_instance_type" {
  description = "Frontend builds Angular on the box; t3.small avoids OOM"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Existing EC2 key pair name (leave empty to disable SSH)"
  type        = string
  default     = ""
}

variable "ssh_cidr" {
  description = "Your IP /32 that may SSH (set to your public IP)"
  type        = string
  default     = "0.0.0.0/0"
}

# --- DB ---
variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_username" {
  type    = string
  default = "appuser"
}

variable "db_password" {
  description = "RDS master password (mark sensitive). Pass via -var or TF_VAR_db_password"
  type        = string
  sensitive   = true
}
