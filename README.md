docker-moodle
=============

A Dockerfile that installs the latest Moodle, Apache and PHP. This uses the official MySQL images from Docker Hub.

## Pre-setup

install docker & compose plugin: [https://docs.docker.com/engine/install/ubuntu/]

```sh
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## Moodle Version 4.1.4+
based on ubuntu/22.04 docker image (which accept php 8.0)


Plugins
* Learner Theme 4.2.r7(Formly Fordson Theme)
* SAML2: 2022111701 [[disabled]]
* Questionnaire: 4.0.1
* H5P: 1.23.2
* EJSApp: 4.0
* EJSApp/Open Source Physics: 1.3
* EJSApp/Remlab: 1.2
* Moosh 1.11
* Level up!: 3.14.1  (Gamification)
* EmailTest: 2.0.2 (System)
* Scheduler: 4.7.0
* JazzQuiz: 1.2.0
* Ad-hoc database queries: 4.2 
* Course size: 4.1

Removed: 
* BigBlueButton (included in moodle 4)
* Pumukit (Video server)
* knockplop (p2p meeting)
* ownCloud: v3.6-r1 [[disabled]]
* easy enrollement
* DSpace Repository: 1.0.0 [[disabled]]
* SWORD Upload Repository: 0.9 [[disabled]]
* Category auto enrol: alpha (?useness?)
* Logqtore xAPI: v4.6.0[[disabled]]
* Statistics module: 2019052802
* Select eduOER content: 2018031402 [[???]]

## update mysql 5.6 to 5.7
It's needed to run `mysql_upgrade` inside the container
```
docker compose up -d
docker exec -it docker-moodle-mysql-1 bash
mysql_upgade -uroot -p$MYSQL_ROOT_PASSWORD
```

## Setup
```
git clone https://github.com/up2university/docker-moodle.git
cd docker-moodle
```

Populate ```envs/``` (based on the contents of ```envs-templates/```) to specify local details, especially ```common.env```:

```
MYSQL_ROOT_PASSWORD=MyMy5QLPas$word
MOODLE_PASSWORD=MyM00Dl3Pas$word
VIRTUAL_HOST=localhost
```
and fill out other ```.env``` files from ```/envs-templates``` for automatic
configuration of any needed tools/integrations.

Create a directory ```./data/``` to hold persistent data.

## Usage

To spawn a new instance of Moodle:

```
docker-compose build
docker-compose up -d
```
and, in a separate terminal, once the Docker containers are running,

```
docker-compose exec moodle /configure.sh
docker-compose exec mysql /configure.sh
```
to configure from the ```/envs/``` directory.

You can visit the following URL in a browser to get started:

```
https://localhost/
```

Thanks to [sergiogomez](https://github.com/sergiogomez), [eugeneware](https://github.com/eugeneware) and [ricardoamaro](https://github.com/ricardoamaro) for their Dockerfiles.

## SSL certificates

By default a self-signed certificate is created. It is enough for local instances.

Setting up a public instance, edit ```envs/common.env``` to includes

```
CURL_OPTS='-k'
```

and do the following:

```
docker-compose exec moodle bash

rm /etc/apache2/sites-enabled/default-ssl.conf
rm -r /etc/letsencrypt/live
/certbot-setup.sh
exit

docker-compose restart moodle
```

To renew the certificate later just run the /certbot-setup.sh within the container.

## Build images

Build the app and push images to Docker Hub:

```
branch=$(git rev-parse --abbrev-ref HEAD)
docker build -t up2university/moodle-mysql:${branch} mysql
docker push up2university/moodle-mysql:${branch}
docker build -t up2university/moodle:${branch} moodle
docker push up2university/moodle:${branch}
```

## Deployment

For the first time put .env file on the host and add DOCKER_TAG=value, specifying which git branch or commit should be deployed on the host. 
Docker images are created for both branches and particular commits, for instance:

* DOCKER_TAG=develop
* DOCKER_TAG=commit-985d87ac2b69c119058a5d290c250e09ed79962b

On deploy upload docker-compose-deploy.yml to the host and run the following there:

```
docker-compose -f docker-compose-deploy.yml pull
docker-compose -f docker-compose-deploy.yml up -d
```

## Known issues

* Sometimes after deployments, changes don’t work until one opens the settings page for particular component and then save it (without changing anything). Spotted for missing CERNBox in the repository list.
