variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}
variable "subnet_count"{
type=map(number)
default={
    public=1,private=2
}
}
variable "ami_id" {

default = "ami-0c7217cdde317cfec"
}
variable "setting"{
  description="configuration setting"
  type=map(any)
  default={
      "database"={
         allocated_storage=10
         engine="mysql"
         engine_version="8.0.35"
         instance_class="db.t2.micro"
         db_name="tutoriel"
         skip_final_snapshot=true

      },
      "web_app"={
        count=1
        instance_type="t2.micro"
      }

  }

}

variable "public_subnet_cidr_blocks"{
     description="availabe CIDR blocks for public subnet"
     type = list(string)
     default= [
      "10.0.1.0/24",
      "10.0.2.0/24",
      "10.0.3.0/24",
      "10.0.4.0/24",
 ]


}
variable "private_subnet_cidr_blocks"{
     description="availabe CIDR blocks for public subnet"
     type = list(string)
     default= [
      "10.0.101.0/24",
      "10.0.102.0/24",
      "10.0.103.0/24",
      "10.0.104.0/24",
]
}
variable "db_username"{
description="Database master user"
type=string
sensitive =true
}

variable "db_password"{
description="Database master user"
type=string
sensitive =true
}
