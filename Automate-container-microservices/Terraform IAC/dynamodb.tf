resource "aws_dynamodb_table" "todotable" {
  name           = "todotable"  # Name of the DynamoDB table
  billing_mode   = "PAY_PER_REQUEST"  # On-demand read/write capacity

  hash_key       = "TodoId"  # Partition key (hash key)

  attribute {
    name = "TodoId"
    type = "N"  # 'S' stands for String type
  }
}
