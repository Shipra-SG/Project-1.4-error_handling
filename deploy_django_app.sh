#!/bin/bash


<< task
Deploy a Django app
and handle the code for errors
task

code_clone() {
    echo "Cloning the Django app..."
    if [ -d "django-notes-app" ]; then
        echo "Code directory already exists, skipping clone"
    else
        git clone https://github.com/Shipra-SG/django-notes-app.git
    fi
}


install_requirements() {
	echo "Installing dependencies"
        sudo apt-get update -y
        sudo apt-get install -y docker.io nginx
}

required_restarts() {
	sudo systemctl enable docker
	sudo systemctl enable nginx
	sudo systemctl restart docker
}

stop_remove_old_container() {
        docker ps -a | grep -q notes-container
	echo "Removing old container..."
	docker rm -f notes-container
}

remove_old_images() {
	docker images | grep -q notes-app
        echo "Removing old image..."
        docker rmi -f notes-app
}

deploy() {
	echo "Deploying application..."

    cd django-notes-app|| exit 1

    docker build --no-cache -t notes-app .

    docker rm -f notes-container 2>/dev/null

    docker run -d \
      --name notes-container \
      -p 8000:8000 \
      notes-app

}


echo "********** DEPLOYMENT STARTED **********"

code_clone

if ! install_requirements; then
	echo "Installation failed"
	exit 1
fi

if ! required_restarts; then
	echo "System fault identified"
	exit 1
fi

stop_remove_old_container
remove_old_images

if ! deploy; then
	echo "Deployment failed, mailing the admin"
	#sendmail
fi


echo "********** DEPLOYMENT DONE **********"
