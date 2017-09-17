#README file for Terraform project
#1 - Simple Architecture - A single Web server running as an AWS EC2 instance that responds to HTTP requests with a simple "Hello, world" page.
# User_data Bash script writes "Hello, World" text to index.html and runs Busybox to fire up a web server serving file requests on port 8080
# busybox command wrapped with nohup and & so that the server runs permanently in the background and the bash script itself can exit
