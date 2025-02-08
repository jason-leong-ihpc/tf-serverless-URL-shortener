
resource "aws_dynamodb_table" "table" {
  name         = "${local.name_prefix}-UrLShortener-DynamoDBs"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "year"

  attribute {
    name = "year"
    type = "" # todo: fill with apporpriate value
  }

}