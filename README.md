# To-Do List Application with Docker and Kubernetes (GKE)

This is a simple command-line To-Do List application written in python. The app allows users to manage tasks, including adding new tasks, viewing existing ones, and removing completed tasks. It creates a text file 'todo_list.txt' to store tasks persistently. Each task has a unique identifier (UUID), a task description and a deadline.

The project demonstrates the process of containerizing a Python application with Docker, pushing the image to DockerHub, and deploying it on a Google Kubernetes Engine (GKE) cluster.

## Features

- Add new tasks with a unique ID, description, and deadline.
- Display all tasks currently stored in the to-do list.
- Mark tasks as completed by removing them from the list.
- Data is stored in a text file 'todo_list.txt' to persist between sessions.
- Docker containerization for easy deployment.

## Steps Involved

1. **Define the Dockerfile**

```
FROM python:3.9-slim
WORKDIR /cli-app
COPY code.py /cli-app
CMD [ "python", "code.py" ]
```

2. **Build the Docker Image**

In the directory of the `Dockerfile`, run the following Docker command to build the image:

```
docker build -t todo_list_image:v1 .
```

This will:
- Use the `Dockerfile` to create a Docker image called `todo_list_image:v1`.
- Sets the base image to `python:3.9-slim` and the working directory as `/cli-app` and copies the `code.py` file into the container.
- Run the Python script `code.py` to start the application.

3. **Tag the Docker Image to prepare for the Push**

After building the Docker image, tag the image for Docker Hub:

```
docker tag todo_list_image:v1 moina512/python-todo-list-repo:v1
```

This command tags the local image `todo_list_image:v1` with the appropriate repository name and tag `moina512/python-todo-list-repo:v1`.

4. **Log in to Docker Hub**

```
docker login
```

You will be prompted to enter your Docker Hub username and password.

5. **Push the Docker Image to Docker Hub**

Push the tagged image to a Docker Hub repository:

```
docker push moina512/python-todo-list-repo:v1
```

This command uploads the image to Docker Hub under the `moina512/python-todo-list-repo` repository with the `v1` tag. The image is now accessible from any machine.

6. **Run the Docker Container (on any machine)**

Once the image is uploaded to Docker Hub, run the Docker container from the image with the following command:

```
docker run -it --rm moina512/python-todo-list-repo:v1
```

- The `-it` flag allows interactive mode so you can interact with the application.
- The `--rm` flag ensures the container is removed once you exit.

This step is to ensure that the application runs successfully as a container. 

7. **Interact with the To-To List Application**

Once the container is running, the application will prmopt you with the following options:

```
    == TODO LIST ==  
    [1] show task    
    [2] add task     
    [3] complete task
    [4] exit
```

- [1] **show task**: Displays all tasks with their IDs, descriptions, and deadlines. 
- [2] **add task**: Add a new task by providing a description and deadline. The task will be assigned a unique ID.
- [3] **complete task**: Remove a task by entering its ID. This will mark as completed and delete it from the list.
- [4] **exit**: Exit the application.

8. **Stop the Docker Container**

To stop the container and exit the application, simply type `4`. This will exit the application and remove the container since `--rm` was used.

## Error Handling:

- If any error occurs while reading or writing to the file, the program will display an error message.
- Invalid menu choices with prompt user to try again.

# Deploying the Application on GKE

## Steps to Deploy on GKE

In GCP console, used Cloud Shell to execute the deployment.

1. **Authenticate GCP CLI**

Start by authenticating the GCP account: 

```
gcloud auth login
```

2. **Set the GCP Project**

Set the project to work with:

```
gcloud config set project PROJECT_ID
```

3. **Create a GKE Cluster**

Create a GKE cluster using the following command:

```
gcloud container clusters create CLUSTER_NAME \
  --zone ZONE \
  --num-nodes 1
```

4. **Configure kubectl to USE GKE Cluster**

Configure `kubectl` to interact with the GKE cluster:

```
gcloud container clusters get-credentials CLUSTER_NAME --zone ZONE --project PROJECT_ID
```

5. **Create Kubernetes Deployment**

Define a **Deployment** resource to manage the application pods i.e. `deployment.yaml`.

- `deployment.yaml`

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: todo-app
  labels:
    app: todo-list
spec:
  replicas: 1
  selector:
    matchLabels:
      app: todo-list
  template:
    metadata:
      labels:
        app: todo-list
    spec:
      containers:
      - name: todo-c
        image: moina512/python-todo-list-repo:v1
        command: ["python", "code.py"]
        stdin: true #enable interactive input
        tty: true #allocate TTY for interactive sessions
        ports:
        - containerPort: 80
```

The **Deployment** will pull the Docker image from DockerHub and run it in the Kubernetes cluster.

6. **Deploy to GKE**

Apply the Kubernetes configuration to deploy the app:

```
kubectl create -f deployment.yaml
kubectl create -f service.yaml
```

7. **Verify Deployment**

Check if the pod(s) is running successfully:

```
kubectl get pods
```

You should see a pod running with the name `todo-app-<random-string>`.

7. **Access the App**

Since this is a **CLI application**, it does not expose a web endpoint. We can **exec** into a running pod and interact with the Todo List inside the container.

```
kubectl exec -it todo-app-<random-string> -- python code.py
```