# main.tf

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.13.0"
    }
  }
}

variable "container_name" {
  description = "Value of the name for the Docker container"
  type        = string
  default     = "ExampleNginxContainer"
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

resource "docker_image" "mariadb" {
  name         = "mariadb:10.10"
  keep_locally = true
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "tutorial"
  ports {
    internal = 80
    external = 8080
  }
}

resource "docker_container" "mariadb" {
  image = docker_image.mariadb.image_id
  name  = "mariadbc"
  ports {
    internal = 3306
    external = 3306
  }
}

output "container_id" {
  description = "ID of the Docker container"
  value       = docker_container.nginx.id
}

output "image_id" {
  description = "ID of the Docker image"
  value       = docker_image.nginx.id

}
resource "local_file" "private_info" {
  content  = "<html><body><h1>My First and Lastname <h1><br><h3>"
  filename = "id.txt"
  provisioner "local-exec" {
    command    = "cat ./id.txt > index.html && echo ${docker_container.nginx.id} >> index.html && echo '</h3><br>' >> index.html && docker cp ./index.html tutorial:/usr/share/nginx/html"
    on_failure = continue
  }
}


resource "time_sleep" "wait_10_seconds" {
  depends_on = [local_file.private_info]

  create_duration = "10s"
}


#resource "null_resource" "readcontentfile" {
#  provisioner "local-exec" {
#    command     = "start chrome http://localhost:8080/index.html"
#    interpreter = ["PowerShell", "-Command"]
#  }
#  depends_on = [time_sleep.wait_10_seconds]
#}
