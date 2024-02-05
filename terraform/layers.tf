###########
# Layer 1 #
###########
resource "null_resource" "layer1_exporter" {
  triggers = {
    index = "${base64sha256(file("../api/layers/layer_1/index.js"))}"
  }
}

data "null_data_source" "wait_for_layer1_exporter" {
  inputs = {
    # This ensures that this data resource will not be evaluated until
    # after the null_resource has been created.
    lambda_exporter_id = null_resource.layer1_exporter.id

    # This value gives us something to implicitly depend on
    # in the archive_file below.
    source_dir = "../api/layers/layer_1/"
  }
}

data "archive_file" "layer1_exporter" {
  output_path = "../api/layers/layer_1.zip"
  source_dir  = "${data.null_data_source.wait_for_layer1_exporter.outputs["source_dir"]}"
  type        = "zip"
}

resource "aws_lambda_layer_version" "lambda_layer" {
  depends_on = [ data.archive_file.layer1_exporter ]
  filename   = "../api/layers/layer_1.zip"
  layer_name = "layer_1"

  compatible_runtimes = ["nodejs20.x"]
}

###########
# Layer 2 #
###########
resource "null_resource" "layer2_exporter" {
  triggers = {
    index = "${base64sha256(file("../api/layers/layer_2/index.js"))}"
  }
}

data "null_data_source" "wait_for_layer2_exporter" {
  inputs = {
    # This ensures that this data resource will not be evaluated until
    # after the null_resource has been created.
    lambda_exporter_id = null_resource.layer2_exporter.id

    # This value gives us something to implicitly depend on
    # in the archive_file below.
    source_dir = "../api/layers/layer_2/"
  }
}

data "archive_file" "layer2_exporter" {
  output_path = "../api/layers/layer_2.zip"
  source_dir  = "${data.null_data_source.wait_for_layer2_exporter.outputs["source_dir"]}"
  type        = "zip"
}

resource "aws_lambda_layer_version" "lambda_layer2" {
  depends_on = [ data.archive_file.layer2_exporter ]
  filename   = "../api/layers/layer_2.zip"
  layer_name = "layer_2"

  compatible_runtimes = ["nodejs20.x"]
}