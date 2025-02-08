provider "aws" {
  region  = "ap-southeast-1a"
  version = "~> 2.0"
}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "UrLShortener-DynamoDB"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "UserId"
  range_key      = "Name"

}