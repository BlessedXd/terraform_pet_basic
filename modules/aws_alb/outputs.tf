#====================================================
# Author: Валерій Мануйлик
#====================================================
# Виведення ARN Load Balancer та Target Group
# Ці значення можуть бути використані в інших модулях або для спостереження за ресурсами.
# GitHub: https://github.com/BlessedXd
#====================================================

# Виведення ARN Application Load Balancer.
output "app_lb_arn" {
    value = aws_lb.app_lb.arn  # ARN Load Balancer.
}

# Виведення ARN Target Group.
output "app_tg_arn" {
    value = aws_lb_target_group.app_tg.arn  # ARN Target Group.
}
