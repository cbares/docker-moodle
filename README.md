docker-moodle
=============

A Dockerfile that installs the latest Moodle, Apache and PHP. This uses the official MySQL images from Docker Hub.

## Pre-setup

install docker: [https://docs.docker.com/engine/install/ubuntu/]

install docker-compose: [https://docs.docker.com/compose/install/]


## Moodle Version 3.11.7+
based on ubuntu/20.04 docker image (because 22.04 had php 8.0 which is not yet recommanded for production by Moodle team)

Updated Plugins:
* EmailTest: 2.0.0   (System)
* Level up!: 3.12.1  (Gamification)


Old Plugins
* BigBlueButton: 2.4.7
* EJSApp: 3.1
* H5P: 1.22.4
* JazzQuiz: 1.0.1
* Knockplop: 1.0.1
* Questionnaire: 3.11.1
* Scheduler: 3.7.0
* Category auto enrol: alpha (?useness?)
* Remlab manager: 1.2
* BlockXP: 3.12.1
* Pumukit Personnal Recorder filter: 2017121200 [[disabled]] (useness?) 
* Select eduOER content: 2018031402
* PuMuKit PersonalRecorder (Atto): 2018072000 (useness?)
* Easy enrollement: v1.7.1 [[disabled]]
* SAML2: 2022060900 [[disabled]]
* Logqtore xAPI: v4.6.0[[disabled]]
* Course size: 4.1
* Ad-hoc database queries: 4.2
* DSpace Repository: 1.0.0 [[disabled]]
* Open Source Physics: 1.3
* ownCloud: v3.6-r1 [[disabled]]
* SWORD Upload Repository: 0.9 [[disabled]]
* Fordson (Theme): v3.11 - release 1
* local Email Test: 2.0.0
* Statistics module: 2019052802


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
