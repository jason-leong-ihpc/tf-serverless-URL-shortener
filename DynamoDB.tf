
# resource "aws_dynamodb_table" "table" {
#   name         = "${local.name_prefix}-UrLShortener-DynamoDBs"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "year"

#   attribute {
#     name = "year"
#     type = "" # todo: fill with apporpriate value
#   }

# }

resource "aws_dynamodb_table" "shortener_table" {
  name         = "${local.name_prefix}-urlshortener-table"
  hash_key     = "short_id"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "short_id"
    type = "S"
  }
}