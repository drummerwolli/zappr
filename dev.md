# Local Development

This guide is for developers who want to run Zappr on their development machine.
In the end you will have three different processes running:
- Your local PostgreSQL database
- Your local Zappr application
- a VPN tunnel (e.g.: localtunnel) exposing your localhost

## pre-requisites

- node
- npm
- docker
- docker-compose

## tl;dr
replace the first three lines with your data. then execute all line by line.

```shell
export GITHUB_CLIENT_ID=<your-client-id>
export GITHUB_CLIENT_SECRET=<your-client-secret>
export VPN_TUNNEL_NAME=<your-app-name>

export HOST_ADDR=https://$VPN_TUNNEL_NAME.localtunnel.me

docker-compose up -d

./init_db.sh

npm i -g localtunnel
lt -s $VPN_TUNNEL_NAME -p 3000
```

## Explanation

### Preconditions

**Before you start** you need to register an OAuth application in your GitHub account under `Settings/ Developer Settings/ OAuth Apps`.   
If you need help in registering your application follow these [instructions](https://auth0.com/docs/connections/social/github).
You will need
- the `Client ID`
- the `Client Secret` and
- the `Authorization callback URL`   

from your registered application later.  
In case you use localtunnel as your VPN, set the `Authorization callback URL` in your GitHub settings to `https://<your-app-name>.localtunnel.me`.

### Database Setup

Zappr needs a database during development. For this reason there's a `docker-compose.yaml`
for your convenience, with which you can start a database for development. 

Start database and schemas:
~~~ shell
# Starts the postgres docker container for development purposes
docker-compose up -d postgres-dev

# Inspect if the DB is up and running
docker-compose logs

# When the DB is up and running create a database and schemas. 
# Only needed first time after starting up DB
./init_db.sh
~~~

### Env Setup

To get your `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` copy it from your Github `Settings/ Developer Settings/ OAuth Apps` or
create them new following these [instructions](https://auth0.com/docs/connections/social/github).
Export your [Github credentials](https://github.com/settings/applications):

~~~ shell
export GITHUB_CLIENT_ID=<your-client-id>
export GITHUB_CLIENT_SECRET=<your-client-secret>
~~~

---

### NPM Setup

install now all dependencies for npm and build the project:

```shell
npm install
npm run build

```

### Localtunel Setup

Install and run localtunnel to expose your localhost in a separate terminal window

~~~ shell
npm i -g localtunnel
lt -s <your-app-name> -p 3000
~~~

Double check that your Authorization callback URL is set to `https://<your-app-name>.localtunnel.me` in the GitHub settings.

### Run Zappr

You can now run Zappr. you need to pass one more env var, to specify where the VPN tunnel can be reached. 

~~~ shell
export HOST_ADDR=https://<your-app-name>.localtunnel.me
npm run all
~~~

Go to `https://<your-app-name>.localtunnel.me` and do things :)

## Docker compose

Currently, there is an issue with using just docker-compose. Generally, once you have configured your shell environment with all the necessary `GLOBALS` described before, you should just run `docker-compose up zappr`. This will run the zappr application and

  ~~~ shell
  docker-compose up zappr
  ~~~

You should be able now to access your local Zappr installation at `http://localhost:3000`.

  You can also set the `GITHUB_CLIENT_ID`, the `GITHUB_CLIENT_SECRET` and the `HOST_ADDR` in your `config/config.yaml` or add it
  to the package.json script.
  However we do not advise it since you could end up pushing your ID and Secret to GitHub.

# Debug Client and Server:

```
npm run build
GITHUB_CLIENT_ID=<your-client-id>
GITHUB_CLIENT_SECRET=<your-client-secret>
HOST_ADDR=https://<your-app-name>.localtunnel.me/
npm run all
```

Enable debug logs...

...in the terminal:

```
export DEBUG="zappr:*"
```

...in the browser console:

```
window.DEBUG.enable('zappr:*')
```

## Test:  
_Note:_ If you want to run tests with local setup please change the local running port of your test database in `docker-compose.yaml`.  

First start the testing database:

~~~ shell
export DB_HOST="$(docker-machine ip)"

# creates database and schemas, only needed first time
./init_db.sh

# start postgres docker container
docker-compose up postgres-test
~~~

Then you can do:

* `npm test` - run combined tests
* `npm run test-client` - run only client tests
* `npm run test-server` - run only server tests
* `npm run test-karma` - run Karma (UI) tests

## Docker Image:

1. Check out `master` and clean up your `git status`
2. Run the build script:

        ./tools/build.sh (<tag>)

* `NPM_BUILD_INSIDE_CONTAINER` "true" to build inside a container
* `DOCKER_ARTIFACT_FILE` file to store docker artifact name in

## Trouble shooting

### No default docker machine
Error:
~~~ shell
$ docker-machine start
Error: No machine name(s) specified and no "default" machine exists
~~~

Workaround:
~~~ shell
# docker-machine create -d "[driver]" [label]
# e.g.
docker-machine create -d "virtualbox" default
~~~

### Can't connect to docker daemon

Error:
~~~ shell
$ ./init_db.sh
Set up dev database
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
...
Set up test database
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
...
~~~

Workaround:
~~~ shell
eval "$(docker-machine env default)"
~~~

### App crashed immediately after running `npm run all `

This happened during Hack Week when docker was not configured correctly. This is most likely related to docker configuration.

Error:
~~~ shell
[nodemon] restarting due to changes...
[nodemon] starting `node dist/server/server.min.js`
[nodemon] app crashed - waiting for file changes before starting...
~~~

Workaround:
~~~ shell
eval "$(docker-machine env default)"
docker-compuse up postgres-dev
~~~

In the CLI tab where you are running the database. `docker-compose` seems to not configured properly in these cases (happens when you're using Mac OS X with Docker Toolbox).

### Container zappr-postgres-dev or zappr-postgres-test missing
Error:
~~~ shell
$ ./init_db.sh
...
Error: No such container: zappr-postgres-dev
...
Error: No such container: zappr-postgres-test
~~~

Workaround:
run one of:
~~~ shell
docker-compose up postgres-dev
docker-compose up postgres-test
~~~
to create the missing container

### Can not start zappr-postgres-dev or zappr-postgres-test service
Error:
~~~ shell
$ docker-compose up postgres-dev|test
ERROR: for zappr-postgres-dev  Cannot start service postgres-dev|test: driver failed
...
~~~

Workaround:
do run **either**
~~~ shell
docker-compose up postgres-dev
~~~
**or**
~~~ shell
docker-compose up postgres-test
~~~
at the same time in different terminal sessions.

### Docker compose up - COPY fails with missing _dist_ directory
Error:
~~~ shell
$ docker-compose up
...
Step 9/15 : COPY dist/ $ZAPPR_HOME/dist
ERROR: Service 'zappr' failed to build: COPY failed: stat /mnt/sda1/var/lib/docker/tmp/docker-builder700929514/dist: no such file or directory
~~~

Workaround:
run
~~~ shell
npm run build
~~~
to create a _dist_ directory the [Dockerfile](https://github.com/zalando/zappr/blob/master/Dockerfile#L17) is expecting

### npm error code ELIFECYCLE
Error:
~~~ shell
$ npm start
...
npm ERR! code ELIFECYCLE
...
~~~

Workaround:
make sure you run the database and zappr in different Terminals e.g.

- Terminal 1
  ~~~ shell
  $ docker-compose up postgres-dev
  ~~~

  or

  ~~~ shell
  $ ./run-zappr-local-terminal01.sh
  ~~~

- Terminal 2
  ~~~ shell
  GITHUB_CLIENT_ID=<your-client-id> GITHUB_CLIENT_SECRET=<your-client-secret> HOST_ADDR=https://<your-app-name>.localtunnel.me/ npm run all
  ~~~

  or

  ~~~ shell
  $ ./run-zappr-local-terminal02.sh
  ~~~
