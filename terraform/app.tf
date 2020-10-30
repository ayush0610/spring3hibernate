resource "aws_ecs_task_definition" "task-definition-test" {
  family                = "app-family"
  container_definitions = file("container-definitions/container-def.json")
  network_mode          = "bridge"
}

resource "aws_ecs_service" "service" {
  name            = "web-service"
  cluster         = "${aws_ecs_cluster.web-cluster.id}"
  task_definition = "${aws_ecs_task_definition.task-definition-test.arn}"
  desired_count   = 2
  load_balancer {
    target_group_arn = "${aws_lb_target_group.lb_target_group.arn}"
    container_name   = "nginx"
    container_port   = "80"
  }
  lifecycle {
    ignore_changes = [desired_count]
  }
  launch_type = "EC2"
  depends_on  = [aws_lb_listener.web-listener]
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/frontend-container"
}

