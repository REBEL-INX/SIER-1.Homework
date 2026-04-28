# Create output file displaying VPC name.

output "vpc_name" {
  value = google_compute_network.week7vpc_network.name
  
}

output "file_content" {
  value = local_file.favorite_food.content  
}