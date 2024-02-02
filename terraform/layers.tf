resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "hello_world.zip"
  layer_name = "layer_1"

  compatible_runtimes = ["nodejs20.x"]
}

resource "aws_lambda_layer_version" "lambda_layer2" {
  filename   = "hello_world.zip"
  layer_name = "layer_2"

  compatible_runtimes = ["nodejs20.x"]
}
