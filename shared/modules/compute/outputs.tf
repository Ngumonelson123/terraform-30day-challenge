# modules/compute/outputs.tf
# DAY 15: alb_dns_name flows into the Cloudflare record in root main.tf

output "alb_dns_name"        { value = aws_lb.app.dns_name }
output "alb_zone_id"         { value = aws_lb.app.zone_id }
output "asg_name"            { value = aws_autoscaling_group.app.name }
output "target_group_arn"    { value = aws_lb_target_group.app.arn }
