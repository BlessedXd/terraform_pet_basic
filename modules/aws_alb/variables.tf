#====================================================
# Author: Валерій Мануйлик
#====================================================
# Змінна для визначення середовища розгортання.
# Ця змінна використовується для ідентифікації середовища, наприклад, dev, staging, production.
# GitHub: https://github.com/BlessedXd
#====================================================

variable "env" {
    default = "dev"  # Значення за замовчуванням - середовище розробки.
}

variable "security_groups" {
  description = "its a sg for my lb"
  type = list
}


variable "public_subnets" {
  description = "it's a public subnet for alb"
  type = list
}

variable "vpc_id" {
  description = "its a vpc id for my lb"
  type = string
}