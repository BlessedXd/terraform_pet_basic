variable "vpc_cidr" {
  description = "CIDR блок для VPC"
  type        = string
  default     = "10.0.0.0/16"  # можна змінити на значення за замовчуванням
}

variable "public_subnet_cidrs" {
  description = "CIDR блоки для публічних підмереж"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}


# Змінна для CIDR блоків приватних підмереж.
# Це список CIDR блоків для створення приватних підмереж у VPC.
variable "private_subnet_cidrs" {
    default = [
        "10.0.11.0/24",
        "10.0.22.0/24",
        "10.0.33.0/24"
    ]
}

# Змінна для списку портів, які потрібно відкрити на сервері.
# Використовується для налаштування правил безпеки в групі безпеки.
variable "allow_ports" {
    description = "List of Ports to open for server"  # Опис змінної.
    default = ["80", "443", "3000"]  # Список портів для відкриття.
}
