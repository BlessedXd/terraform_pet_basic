
#====================================================
# Author: Валерій Мануйлик
#====================================================
# Змінні для налаштування VPC, підмереж і портів
# Це дозволяє налаштовувати інфраструктуру за допомогою параметрів
# GitHub: https://github.com/BlessedXd
#====================================================



# Змінна для середовища (наприклад, dev, prod).
# Використовується для іменування ресурсів відповідно до середовища.
variable "env" {
    default = "dev"  # Значення середовища для ресурсу.
}
# variables.tf

variable "vpc_cidr" {
  description = "CIDR блок для VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR блоки для публічних підмереж"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR блоки для приватних підмереж"
  type        = list(string)
}

variable "allow_ports" {
  description = "Порти, які будуть дозволені для доступу"
  type        = list(number)
}

