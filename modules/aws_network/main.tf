#====================================================
# Author: Валерій Мануйлик
#====================================================
# Налаштування мережевої інфраструктури для VPC
# Включає створення VPC, підмереж, NAT шлюзів, маршрутів та груп безпеки
# GitHub: https://github.com/BlessedXd
#====================================================

# Отримання списку доступних Availability Zones для використання при створенні підмереж.
data "aws_availability_zones" "available" {}

# Створення Virtual Private Cloud (VPC).
# Це головна мережа, в межах якої будуть розміщені всі інші ресурси.
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr  # CIDR блок для VPC.

    tags = {
        Name = "${var.env} - vpc"  # Тег для VPC.
    }
}

# Створення Internet Gateway (IGW) для VPC.
# Це дозволяє EC2 інстансам у публічних підмережах підключатися до Інтернету.
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id  # ID VPC, до якого буде прив'язано IGW.

    tags = {
        Name = "${var.env} - igw"  # Тег для IGW.
    }
}

# Створення публічних підмереж у VPC.
# Кожна підмережа отримає публічну IP-адресу при запуску інстансу.
resource "aws_subnet" "public_subnets" {
    count = length(var.public_subnet_cidrs)  # Кількість публічних підмереж.
    vpc_id = aws_vpc.main.id  # ID VPC, до якого будуть прив'язані підмережі.
    cidr_block = element(var.public_subnet_cidrs, count.index)  # CIDR блок для підмережі.
    availability_zone = data.aws_availability_zones.available.names[count.index]  # Availability Zone для підмережі.
    map_public_ip_on_launch = true  # Призначення публічної IP-адреси інстансам при запуску.

    tags = {
        Name = "${var.env} - public - ${count.index + 1}"  # Тег для кожної публічної підмережі.
    }
}

# Створення маршрутної таблиці для публічних підмереж.
# Це дозволяє всім інстансам у публічних підмережах мати доступ до Інтернету через IGW.
resource "aws_route_table" "public_subnets" {
    vpc_id = aws_vpc.main.id  # ID VPC для маршрутної таблиці.

    route {
        cidr_block = "0.0.0.0/0"  # Маршрут для всього Інтернет-трафіку.
        gateway_id = aws_internet_gateway.main.id  # ID IGW для маршрутизації.
    }

    tags = {
        Name = "${var.env} - route-public-subnets"  # Тег для маршрутної таблиці.
    }
}

# Асоціація публічних підмереж з маршрутною таблицею.
resource "aws_route_table_association" "public_routes" {
    count = length(aws_subnet.public_subnets[*].id)  # Кількість асоціацій для публічних підмереж.
    route_table_id = aws_route_table.public_subnets.id  # ID маршрутної таблиці.
    subnet_id = element(aws_subnet.public_subnets[*].id, count.index)  # ID публічної підмережі.
}

# Створення Elastic IP для NAT Gateways.
# Кожна NAT шлюз отримує свій Elastic IP.
resource "aws_eip" "nat" {
    count = length(var.private_subnet_cidrs)  # Кількість NAT шлюзів.
    domain = "vpc"  # Призначення EIP для VPC.

    tags = {
        Name = "${var.env} - nat-gw- ${count.index + 1}"  # Тег для кожного EIP.
    }
}

# Створення NAT Gateway для кожної приватної підмережі.
# NAT шлюзи забезпечують вихід до Інтернету для інстансів у приватних підмережах.
resource "aws_nat_gateway" "nat" {
    count = length(var.private_subnet_cidrs)  # Кількість NAT шлюзів.
    allocation_id = aws_eip.nat[count.index].id  # ID EIP для NAT шлюзу.
    subnet_id = element(aws_subnet.public_subnets[*].id, count.index)  # ID публічної підмережі, де розміщується NAT шлюз.

    tags = {
        Name = "${var.env} - nat-gw - ${count.index + 1}"  # Тег для кожного NAT шлюзу.
    }
}

# Створення приватних підмереж у VPC.
# Ці підмережі не мають прямого доступу до Інтернету.
resource "aws_subnet" "private_subnets" {
    count = length(var.private_subnet_cidrs)  # Кількість приватних підмереж.
    vpc_id = aws_vpc.main.id  # ID VPC, до якого будуть прив'язані підмережі.
    cidr_block = element(var.private_subnet_cidrs, count.index)  # CIDR блок для підмережі.
    availability_zone = data.aws_availability_zones.available.names[count.index]  # Availability Zone для підмережі.

    tags = {
        Name = "${var.env} - private - ${count.index + 1}"  # Тег для кожної приватної підмережі.
    }
}

# Створення маршрутної таблиці для приватних підмереж.
# Це дозволяє приватним підмережам використовувати NAT шлюзи для доступу до Інтернету.
resource "aws_route_table" "private_subnets" {
    count = length(var.private_subnet_cidrs)  # Кількість маршрутних таблиць.
    vpc_id = aws_vpc.main.id  # ID VPC для маршрутної таблиці.
    route {
        cidr_block = "0.0.0.0/0"  # Маршрут для всього Інтернет-трафіку.
        nat_gateway_id = aws_nat_gateway.nat[count.index].id  # ID NAT шлюзу для маршрутизації.
    }

    tags = {
        Name = "${var.env} - route-private-subnet- ${count.index + 1}"  # Тег для маршрутної таблиці.
    }
}

# Асоціація приватних підмереж з маршрутною таблицею.
resource "aws_route_table_association" "private_routes" {
    count = length(aws_subnet.private_subnets[*].id)  # Кількість асоціацій для приватних підмереж.
    route_table_id = aws_route_table.private_subnets[count.index].id  # ID маршрутної таблиці.
    subnet_id = element(aws_subnet.private_subnets[*].id, count.index)  # ID приватної підмережі.
}

# Створення групи безпеки (Security Group).
# Ця група безпеки визначає правила вхідного та вихідного трафіку для інстансів у VPC.
resource "aws_security_group" "dev_sg" {
    vpc_id = aws_vpc.main.id  # ID VPC, до якого буде прив'язана група безпеки.

    # Динамічне створення правил для вхідного трафіку.
    dynamic "ingress" {
        for_each = var.allow_ports  # Список портів, для яких створюються правила.
        content {
            from_port   = ingress.value  # Початковий порт для правила.
            to_port     = ingress.value  # Кінцевий порт для правила.
            protocol    = "tcp"  # Протокол для правила (TCP).
            cidr_blocks = ["0.0.0.0/0"]  # Дозволити доступ з будь-якої IP-адреси.
        }
    }

    # Правила для вихідного трафіку.
    egress {
        from_port   = 0  # Початковий порт для вихідного трафіку.
        to_port     = 0  # Кінцевий порт для вихідного трафіку.
        protocol    = "-1"  # Протокол для вихідного трафіку (всі протоколи).
        cidr_blocks = ["0.0.0.0/0"]  # Дозволити доступ до будь-якої IP-адреси.
    }

    tags = {
        Name = "${var.env} - sg"  # Тег для групи безпеки.
    }
}
