# Docker local "environments" per Git branches

## What are Git Hooks?

Have you ever wondered what are the Git hooks and how can they help you be more "effective & productive" ?

[Git Hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) are basically "scripts" that can run when specific events are being triggered, like you are making a commit, or you are receiving commits from the remote. There are two types of hooks, **client-side** and **server-side**. In this blog post we are going to discover one of the **client-side** hooks named `post-checkout`. These hooks must be present in the `.git/hooks` folder or your project, but it can be changed with the `git config core.hooksPath` command. If you are interested in the basics please check out it this page: https://git-scm.com/docs/githooks

There are projects where the commit messages are being validated via a specific hook to make sure the messages will be having the "conventional commit" style. 

Javascript developers are probably familiar with a tool called [Husky](https://typicode.github.io/husky/#/?id=create-a-hook) it lets you create Git hooks easily installed for the developers. In this blog post we are going to use a Maven project with a Maven plugin that will automatically install hooks into your `.git` repository. 

## What is Docker Compose?

With the help of the [Docker Compose](https://docs.docker.com/compose/) we are able to create so called YAML files, to create and manage docker containers "quickly". We can commit these files to our repositories and other developers are able to set up their dependencies easily when they join a project. When I talk about dependencies I mean databases, messaging services, other services (like Spring based apps that are being containerized).  

For this [Docker](https://docker.com/) and of course the [Docker Compose](https://docs.docker.com/compose/) executables must be installed.

An example with Postgres database - the file named by default must be: **docker-compose.yml** and in the directory the following command must be invoked to start the Postgres container: `docker-compose up`
```yaml
version: '3.7'
services: 
  postgres-db:
    image: postgres:14
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: example
      POSTGRES_PASSWORD: example-password
```

After starting the container (`docker-compose up`) similar logs should appear:
```log
Creating docker-env-with-git-hooks_postgres-db_1 ... done
Attaching to docker-env-with-git-hooks_postgres-db_1
postgres-db_1  | The files belonging to this database system will be owned by user "postgres".
postgres-db_1  | This user must also own the server process.
postgres-db_1  | 
postgres-db_1  | The database cluster will be initialized with locale "en_US.utf8".
postgres-db_1  | The default database encoding has accordingly been set to "UTF8".
postgres-db_1  | The default text search configuration will be set to "english".
postgres-db_1  | 
postgres-db_1  | Data page checksums are disabled.
...
```

In another terminal if we execute the `docker ps` command we should see similar output:
```shell
docker ps
CONTAINER ID   IMAGE        COMMAND                  CREATED          STATUS           PORTS                                    NAMES
17adc0b1b905   postgres:14  "docker-entrypoint.s…"   13 minutes ago   Up 13 minutes   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp docker-env-with-git-hooks_postgres-db_1
```

For me the container ID is **17adc0b1b905** but on your machine it is probably different, most of the columns are self-explanatory but right now I would like to focus on the **NAMES** column, and the name for our container is: **docker-env-with-git-hooks_postgres-db_1**. We did not specify any names, so it needs some explanation.

**docker-env-with-git-hooks_postgres-db_1**:
- docker-env-with-git-hooks - in my case it is the name of the folder where the **docker-compose.yml** is - this can be overwritten with a flag when the `docker-compose` is being called
- postgres-db - this is the name of the **service** we specified in the **docker-compose.yml** file - this can be overwritten with a `container_name` attribute in the **docker-compose.yml** file, but it will overwrite the whole name, nothing else will alternate it.
- 1 - this is replica number of the container, we can scale containers and in those cases their postfix numbers are changing - if we specify the `container_name` attribute for the specific service the number postfix will be gone.

To stop the running container just press `Ctrl+C` in the terminal window where the containers are running or open another terminal window and go to the folder where you started added 

Let's try to play around with the `docker-compose` command and overwrite the folder's name in the container name to **awesome-hooks** with the changed YAML file where we specified a name for the Postgres service.

Run the following command to get more info on the options: `docker-compose --help`
```log
...
Options:
  -f, --file FILE             Specify an alternate compose file
                              (default: docker-compose.yml)
  -p, --project-name NAME     Specify an alternate project name
                              (default: directory name)
  --profile NAME              Specify a profile to enable
  -c, --context NAME          Specify a context name
  --verbose                   Show more output
  --log-level LEVEL           Set log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
  --ansi (never|always|auto)  Control when to print ANSI control characters
  --no-ansi                   Do not print ANSI control characters (DEPRECATED)
  -v, --version               Print version and exit
  -H, --host HOST             Daemon socket to connect to

  --tls                       Use TLS; implied by --tlsverify
  --tlscacert CA_PATH         Trust certs signed only by this CA
  --tlscert CLIENT_CERT_PATH  Path to TLS certificate file
  --tlskey TLS_KEY_PATH       Path to TLS key file
  --tlsverify                 Use TLS and verify the remote
  --skip-hostname-check       Don't check the daemon's hostname against the
                              name specified in the client certificate
  --project-directory PATH    Specify an alternate working directory
                              (default: the path of the Compose file)
  --compatibility             If set, Compose will attempt to convert keys
                              in v3 files to their non-Swarm equivalent (DEPRECATED)
  --env-file PATH             Specify an alternate environment file
...
```

This option key is the important for us:
```log
  -p, --project-name NAME     Specify an alternate project name
                              (default: directory name)
```

Knowing that we are able to change the name for the whole docker-compose project: ``docker-compose --project-name awesome-hooks up``

```log
Creating awesome-hooks_postgres-db_1 ... done
Attaching to awesome-hooks_postgres-db_1
postgres-db_1  | The files belonging to this database system will be owned by user "postgres".
postgres-db_1  | This user must also own the server process.
```

We can already see a change, we see the **medium-post-postgres** value and not the **postgres-db_1** as before. Now let's check the running containers with `docker ps`.

```log
CONTAINER ID   IMAGE       COMMAND                  CREATED          STATUS        PORTS                                     NAMES
d9601ab32d6d   postgres:14 "docker-entrypoint.s…"   11 seconds ago   Up 10 seconds 0.0.0.0:5432->5432/tcp, :::5432->5432/tcp awesome-hooks_postgres-db_1
```

The name of the container now is **awesome-hooks_postgres-db_1**, so the **awesome-hooks** is now used as the prefix. AWESOME.

Just to make sure to write it down as well, all Docker objects (containers, networks, volumes etc) are having that specific prefixes, not only the containers.

## Combine Docker-Compose with Git Hooks

Think about it, you are in a middle of a big feature, you have already made changes to the application's database schema, you added new tables, new columns (that are not nullable), and you have written tons of code and then BUM.

A new message arrives: **Hey, can you check this pull request and write some feedback? - Yes of course! Let me see it.**

Tons of changes in the source code and in the database schema, but you are a good developer, you always check out the code, and you always run the newly created tests, IT tests whatever...

You also know that you have created test data for your new development by hand, and you do not want to lose it, but if you check out and recreate your database you can lose all your "temporary" test data.

There are a tons of good approaches to this kind of situation, like creating a snapshot of your database, or renaming the container and the attached volumes, but it takes time, and you are in a "hurry".

How about creating new containers per git branches? When a branch is being checked out, a new docker-compose project would be launched, the other containers would be stopped, and new containers would be created where the docker-compose project's name would include the git branch name.

For example, a docker-compose file with the previous Postgres service on a branch named **feature/ABC-1123-User-profile-management**.

Name our project **Warp** and in this case the container name could be: **warp-feature/ABC-1123-User-profile-management_postgres-db_1** and if the earlier containers are stopped, there will be no clashes with the ports, all your previous data would reside in the other container and your "work" will not be lost.

## Demo

We would like to create a script, that will be copied to the git hook's directory, and it will be launched at every branch checkout.

The script must be made with the name `post-checkout` and it must be copied to the `.git/hooks` folder, and execute permission must be given to it.

From the official documentation we can see that 3 parameters are going to given to that upon execution: https://git-scm.com/docs/githooks#_post_checkout

- $1 - Previous HEAD
- $2 - New HEAD
- $3 - 1 if checking out a branch, 0 if checking out something else, such as a file (rollbacks)

So we are going to receive the SHA values, rather than the branch names we are looking forward, of course we if want to just stay with the SHA values it is also cool, but we are aiming for the branch names.
