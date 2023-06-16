#!/bin/bash

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if docker is installed, and install if missing
if ! command_exists docker; then
  echo "Docker not found. Installing Docker..."
  # Add commands to install Docker based on your system
fi

# Check if docker-compose is installed, and install if missing
if ! command_exists docker-compose; then
  echo "Docker Compose not found. Installing Docker Compose..."
  # Add commands to install Docker Compose based on your system
fi

# Create a WordPress site
create_wordpress_site() {
  if [ -z "$1" ]; then
    echo "Please provide a site name."
    exit 1
  fi

  site_name=$1

  # Create the docker-compose.yml file
  echo "version: '3.8'
services:
  wordpress:
    image: wordpress:latest
    restart: always
    ports:
      - 80:80
    environment:
      - WORDPRESS_DB_HOST=db
      - WORDPRESS_DB_USER=root
      - WORDPRESS_DB_PASSWORD=root
      - WORDPRESS_DB_NAME=$site_name
    volumes:
      - ./wordpress:/var/www/html
  db:
    image: mysql:5.7
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_DATABASE=$site_name
    volumes:
      - ./mysql:/var/lib/mysql" > docker-compose.yml

  # Start the containers
  echo "Creating the WordPress site..."
  docker-compose up -d

  # Add entry to /etc/hosts
  echo "127.0.0.1 $site_name" | sudo tee -a /etc/hosts

  # Prompt user to open the site in the browser
  echo "WordPress site created successfully. Open http://$site_name in your browser."
}

# Enable or disable the site
toggle_site() {
  if [ -z "$1" ]; then
    echo "Please provide a site name."
    exit 1
  fi

  site_name=$1

  # Stop or start the containers
  if docker-compose ps | grep -q "$site_name"; then
    echo "Stopping the site..."
    docker-compose stop
  else
    echo "Starting the site..."
    docker-compose start
  fi
}

# Delete the site
delete_site() {
  if [ -z "$1" ]; then
    echo "Please provide a site name."
    exit 1
  fi

  site_name=$1

  # Stop and remove the containers
  echo "Stopping and removing the site..."
  docker-compose down

  # Remove entry from /etc/hosts
  sudo sed -i.bak "/$site_name/d" /etc/hosts

  # Remove local files
  echo "Removing local files..."
  rm -rf wordpress mysql docker-compose.yml

  echo "WordPress site deleted successfully."
}

# Parse command line arguments
case "$1" in
  create)
    create_wordpress_site "$2"
    ;;
  toggle)


    toggle_site "$2"
    ;;
  delete)
    delete_site "$2"
    ;;
  *)
    echo "Usage: $0 {create <site_name> | toggle <site_name> | delete <site_name>}"
    exit 1
esac
