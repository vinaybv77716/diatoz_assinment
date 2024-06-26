#Creating ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "vinay-cluster"
}
#data "aws_ecr_repository" "nodeapp"{
#name = "nodeproj"
#}
data "template_file" "cb_app" {
  template = file("./templates/ecs/cb_app.json.tpl")

  vars = {
    app_image      = "890405391444.dkr.ecr.us-east-1.amazonaws.com/nodeproj"
    app_port       = var.app_port #8080
    fargate_cpu    = var.fargate_cpu  #1024
    fargate_memory = var.fargate_memory  #2048
    aws_region     = var.aws_region  #us-east-1
    tag            = var.tag  # latest
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "vinay-app-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.cb_app.rendered
}

resource "aws_ecs_service" "main" {
  name            = "vinay-service1"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count #2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "vinay-app"
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role]
}
