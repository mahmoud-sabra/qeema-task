# qeema-task
**Note: All pipeline operations will be managed on the `dev` branch.**

**Note: I initially tried to configure the pipeline to trigger only on Git tag creation, but unfortunately, I was not successful. Therefore, I added an additional trigger for push events as a fallback.**

**Note: Additionally, I set up domains and configured reverse proxies for Jenkins, the deployed application, and SonarQube to properly route traffic and ensure secure access**
## 📦 Project Overview

This repository contains a Jenkins CI/CD pipeline for a Java Maven application. 
The pipeline automates building, testing (via SonarQube), containerizing, and deploying the application.

---

## 🎯 Deliverables

✅ A Jenkins pipeline that performs the following:

1. **Checkout**: Pulls source code from the `dev` branch  
2. **Build JAR**: Builds the Java application using Maven (`mvn clean package -DskipTests`)  
3. **Static Code Analysis**: Scans code using **SonarQube**  
4. **Build Docker Image**: Creates a Docker image tagged with Jenkins `BUILD_NUMBER`  
5. **Push Docker Image**: Pushes the image to DockerHub using secure credentials  
6. **Deploy Container**: Runs the Docker container on port `8000`

---

## 📥 Installations

### 🔸 Install SonarQube

Refer to 👉 [How to Install SonarQube by Mahmoud Sabra](https://medium.com/@ma7moudsabra/how-to-install-sonarqube-on-ubuntu-24-04-lts-1e5e36f4a767)

### 🔸 Install Jenkins

Refer to 👉 [Official Jenkins Debian Installation Guide](https://pkg.jenkins.io/debian/)

---

## 🔌 Jenkins Setup

### 🧩 Required Plugins

- Pipeline  
- Git  
- Maven Integration  
- SonarQube Scanner  
- Docker Pipeline  
- Credentials Binding  

---

### 🔐 SonarQube Token Setup

1. Generate a token via **My Account → Security** in SonarQube UI  
2. Store it as a **Secret Text Credential** in Jenkins:
   - **ID**: `sonarqube`

![SonarQube Token](https://github.com/user-attachments/assets/fbf751c7-26e9-4f5a-8c01-b32b50f04458)


---

### 🔐 Jenkins Credentials

Under **Manage Jenkins → Credentials**, add the following:

| Type               | ID        | Description                       |
|--------------------|-----------|-----------------------------------|
| Secret Text        | `sonarqube` | SonarQube token                  |
| Secret Text        | `github`  | GitHub Personal Access Token      |
| Username/Password  | `Docker`  | DockerHub username & token        |

![Docker Credential](https://github.com/user-attachments/assets/5c05268f-3bed-4996-bd65-c82d6345ac46)

---

### ⚙️ Jenkins System Configuration

#### Add SonarQube Server

- Go to: **Manage Jenkins → Configure System**
- Configure SonarQube server using your token and URL

![SonarQube Config](https://github.com/user-attachments/assets/432bdf93-b798-435e-9794-8a255bc2696f)

---

### 🔗 GitHub Integration

- Go to: **Manage Jenkins → Configure System → GitHub Servers**
- Add GitHub server:
  - **Name**: GitHub  
  - **API URL**: `https://api.github.com`  
  - **Credentials**: Use GitHub PAT

![GitHub Server](https://github.com/user-attachments/assets/00e5b46c-16f5-47ef-8e13-5839340c19b6)

---

### 🔔 Webhook Setup (GitHub)

Go to: **GitHub → Settings → Webhooks → Add Webhook**

| Field        | Value                                                      |
|--------------|------------------------------------------------------------|
| Payload URL  | `https://jenkins.dotechwithme.site/github-webhook/`       |
| Content type | `application/json`                                        |
| Events       | Push or Tag creation events                               |
| Secret       | *(optional)*                                              |

![Webhook](https://github.com/user-attachments/assets/295c0ead-bd42-4c4f-b8a9-0d1229d4794c)
![Webhook Success](https://github.com/user-attachments/assets/8fa2f1ec-6432-4a26-8031-7eac772ffc93)

---

### ✅ Test Connection

Make sure Jenkins is reachable via its public URL and GitHub sends a `200 OK` response.

![Connection Test](https://github.com/user-attachments/assets/e3d6a650-c709-4f2c-8581-39f524a1102a)

---

## 🛠️ Jenkins Pipeline Configuration Screenshots

![Config 1](https://github.com/user-attachments/assets/9a5d6038-a25b-45dd-a1d2-df2a97de93f3)  
![Config 2](https://github.com/user-attachments/assets/2fd2e81a-fae3-41db-b2a8-8575c759ce46)  
![Config 3](https://github.com/user-attachments/assets/25711796-5990-4436-8177-544f9ac9de68)  
![Config 4](https://github.com/user-attachments/assets/d2cc5eda-1c3e-478c-abe3-ebb085218fe1)

---

## 🚀 Output & Results

### Jenkins  
![Jenkins Dashboard](https://github.com/user-attachments/assets/f5532f02-ca13-43f4-8b3d-54382ef7af56)

### SonarQube  
![SonarQube Analysis](https://github.com/user-attachments/assets/b927de32-36d8-4f46-bc70-840702c303a0)

### DockerHub  
![DockerHub Repository](https://github.com/user-attachments/assets/52b13b17-9d88-493a-9f1d-8029b3e0e584)

### Domain Setup & Access  
![Domain Configuration](https://github.com/user-attachments/assets/0fc712b8-18ea-43de-8902-ea513e54f1e1)

---

## 🛠️ Tools Used (Optional)

- **DigitalOcean** for creating the droplet  
  ![DigitalOcean Droplet](https://github.com/user-attachments/assets/981da07e-6b19-4cd2-8a85-6fa1bcbae60d)

- **GoDaddy** for managing domain DNS routes  
  ![GoDaddy DNS](https://github.com/user-attachments/assets/e25c85f4-0ac8-4ff7-a9de-9779e5f07b57)

- **Certbot** for automated TLS certificate management  
  [Certbot NGINX TLS Setup](https://certbot.eff.org/instructions?ws=nginx&os=snap)

---

## 🌐 My Domains

- [Jenkins Dashboard](https://jenkins.dotechwithme.site/)  
- [SonarQube Server](https://sonarqube.dotechwithme.site/)  
- [Qeema Application](https://qeema.dotechwithme.site/)









