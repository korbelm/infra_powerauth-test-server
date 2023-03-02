resource "aws_cloudwatch_log_group" "main" {
  name = "/ecs/${var.name_prefix}"
}

data "aws_iam_policy_document" "fargate-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }
}
resource "aws_iam_policy" "fargate_execution" {
  name   = "fargate_execution_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetAuthorizationToken",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "*"
    },
    {
       "Effect": "Allow",
       "Action": [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
       ],
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_policy" "fargate_task" {
  name   = "fargate_task_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "servicediscovery:ListServices",
            "servicediscovery:ListInstances"
        ],
        "Resource": "*"
    },
    {
       "Effect": "Allow",
       "Action": [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
       ],
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role" "fargate_execution" {
  name               = "${var.name_prefix}-fargate-execution-role"
  assume_role_policy = data.aws_iam_policy_document.fargate-role-policy.json
}
resource "aws_iam_role" "fargate_task" {
  name               = "${var.name_prefix}-fargate-task-role"
  assume_role_policy = data.aws_iam_policy_document.fargate-role-policy.json
}
resource "aws_iam_role_policy_attachment" "fargate-execution" {
  role       = aws_iam_role.fargate_execution.name
  policy_arn = aws_iam_policy.fargate_execution.arn
}
resource "aws_iam_role_policy_attachment" "fargate-task" {
  role       = aws_iam_role.fargate_task.name
  policy_arn = aws_iam_policy.fargate_task.arn
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.fargate_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.name_prefix}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.fargate_execution.arn
  task_role_arn            = aws_iam_role.fargate_task.arn
  container_definitions    = jsonencode([
    {
      name         = "${var.name_prefix}-app"
      image        = var.image
      essential    = true
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = var.service_port
          hostPort      = var.service_port
        }
      ]
      logConfiguration = {
        logdriver = "awslogs"
        options   = {
          "awslogs-group"         = "/ecs/${var.name_prefix}"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "stdout"
        }
      }
      environment = var.env_vars
    }
  ])
}

resource "aws_security_group" "ecs" {
  name   = "${var.name_prefix}-ecs-sg"
  vpc_id = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.service_port
    to_port         = var.service_port
    security_groups = [var.alb_sg_id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${var.name_prefix}-ecs-cluster"
}

resource "aws_ecs_service" "main" {
  name            = "${var.name_prefix}-ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"
  enable_execute_command = true

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = data.aws_subnets.default.ids.*
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "${var.name_prefix}-app"
    container_port   = var.service_port
  }
}
