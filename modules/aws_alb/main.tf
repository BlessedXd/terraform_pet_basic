#====================================================
# Author: Валерій Мануйлик
#====================================================
# Модуль створення Application Load Balancer (ALB) і його ресурсів
# Цей код описує створення Load Balancer, Target Group і Listener
# GitHub: https://github.com/BlessedXd
#====================================================

# Створення Application Load Balancer (ALB).
# Цей ресурс створює зовнішній Load Balancer типу "application".
resource "aws_lb" "app_lb" {
    internal           = false  # ALB є зовнішнім (public).
    load_balancer_type = "application"  # Тип Load Balancer - application.
    subnets = var.public_subnets
    enable_deletion_protection = false  # Захист від видалення вимкнено.

    enable_cross_zone_load_balancing = true  # Балансування між зонами ввімкнено.
    tags = {
        Name = "${var.env}-app-lb"  # Ім'я Load Balancer.
    }
}

# Створення Target Group.
# Група цільових інстансів, які будуть отримувати трафік від ALB.
resource "aws_lb_target_group" "app_tg" {
    name     = "app-tg"  # Ім'я Target Group.
    port     = 80  # Порт, на якому Target Group приймає трафік.
    protocol = "HTTP"  # Протокол зв'язку.
    vpc_id   = var.vpc_id
    target_type = "instance"

    health_check {
        path                = "/health"  # Шлях для перевірки стану здоров'я.
        interval            = 30  # Інтервал між перевірками.
        timeout             = 5  # Тайм-аут перевірки.
        healthy_threshold   = 2  # Поріг для позначення інстансу здоровим.
        unhealthy_threshold = 2  # Поріг для позначення інстансу хворим.
    }

    tags = {
        Name = "${var.env}-app-tg"  # Ім'я Target Group.
    }
}

# Створення Listener для Load Balancer.
# Listener визначає, як ALB обробляє вхідний трафік.
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.app_lb.arn  # ARN Load Balancer.
    port              = 80  # Порт, на якому Listener приймає трафік.
    protocol          = "HTTP"  # Протокол зв'язку.

    default_action {
        type             = "forward"  # Тип дії - перенаправлення трафіку.
        target_group_arn = aws_lb_target_group.app_tg.arn  # ARN Target Group для перенаправлення трафіку.
    }
}
