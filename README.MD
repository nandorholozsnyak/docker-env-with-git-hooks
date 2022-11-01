# Docker local "environments" per Git branches

## What are Git Hooks?

Have you ever wondered what are the Git hooks and how can they help you be more "effective & productive" ?

[Git Hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) are basically "scripts" that can run when specific events are being triggered, like you are making a commit, or you are receiving commits from the remote. There are two types of hooks, **client-side** and **server-side**. In this blog post we are going to discover one of the **client-side** hooks named `post-checkout`. These hooks must be present in the `.git/hooks` folder or your project, but it can be changed with the `git config core.hooksPath` command. If you are interested in the basics please check out it this page: https://git-scm.com/docs/githooks

There are projects where the commit messages are being validated via a specific hook to make sure the messages will be having the "conventional commit" style. 

Javascript developers are probably familiar with a tool called [Husky](https://typicode.github.io/husky/#/?id=create-a-hook) it lets you create Git hooks easily installed for the developers. In this blog post we are going to use a Maven project with a Maven plugin that will automatically install hooks into your `.git` repository. 

## What is Docker Compose?

With the help of the [Docker Compose](https://docs.docker.com/compose/) we are able to create so called YAML files, to create and manage containers "quickly". We can commit these files to our repositories and other developers are able to set up their dependencies easily when they join a project. When I talk about dependencies I mean databases, messaging services, other services (like Spring based apps that are being containerized).  

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

Let's break down the name: **docker-env-with-git-hooks_postgres-db_1**:
- **docker-env-with-git-hooks** - in my case it is the name of the folder where the **docker-compose.yml** is - this can be overwritten with a flag when the `docker-compose` is being called
- **postgres-db** - this is the name of the **service** we specified in the **docker-compose.yml** file - this can be overwritten with a `container_name` attribute in the **docker-compose.yml** file, but it will overwrite the whole name, nothing else will alternate it.
- **1** - this is replica number of the container, we can scale containers and in those cases their postfix numbers are changing - if we specify the `container_name` attribute for the specific service the number postfix will be gone.

To stop the running container just press `Ctrl+C` in the terminal window where the containers are running or open another terminal window and go to the folder where the **docker-compose.yml** file resided and inveok the `docker-compose stop` command.

Let's try to play around with the `docker-compose` command and overwrite the folder's name in the container name to **awesome-hooks**.

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

Knowing that we are able to change the name for the whole docker-compose project: `docker-compose --project-name awesome-hooks up`

```log
Creating awesome-hooks_postgres-db_1 ... done
Attaching to awesome-hooks_postgres-db_1
postgres-db_1  | The files belonging to this database system will be owned by user "postgres".
postgres-db_1  | This user must also own the server process.
```

Now let's check the running containers with `docker ps`.

```log
CONTAINER ID   IMAGE       COMMAND                  CREATED          STATUS        PORTS                                     NAMES
d9601ab32d6d   postgres:14 "docker-entrypoint.s…"   11 seconds ago   Up 10 seconds 0.0.0.0:5432->5432/tcp, :::5432->5432/tcp awesome-hooks_postgres-db_1
```

The name of the container now is **awesome-hooks_postgres-db_1**, so the **awesome-hooks** is now used as the prefix. **AWESOME**.

Just to make sure to write it down as well, all Docker objects (containers, networks, volumes etc.) are having that specific prefixes, not only the containers.

## Combine Docker-Compose with Git Hooks

Think about it, you are in a middle of a big feature, you have already made changes to the application's database schema, you added new tables, new columns (that are not nullable), and you have written tons of code and then BUM.

A new message arrives: **Hey, can you check this pull request and write some feedback? - Yes of course! Let me see it.**

Tons of changes in the source code and in the database schema, but you are a good developer, you always check out the code, and you always run the newly created tests, IT tests whatever...

You also know that you have created test data for your new development by hand, and you do not want to lose it, but if you check out and recreate your database you can lose all your "temporary" test data.

There are a tons of good approaches to this kind of situation, like creating a snapshot of your database, or renaming the container and the attached volumes, but it takes time, and you are in a "hurry".

How about creating new containers per git branches? When a branch is being checked out, a new docker-compose project would be launched, the other containers would be stopped, and new containers would be created where the docker-compose project's name would include the git branch name.

For example, a docker-compose file with the previous Postgres service on a branch named **feature/ABC-1123-User-profile-management**.

Name our project **Warp** and in this case the container name could be: **warp-feature/ABC-1123-User-profile-management_postgres-db_1** and if the earlier containers are stopped, there will be no collisions with the ports, all your previous data would be retained in the other container and your "work" will not be lost.

## Demo

Let's create a folder and in that a new git repository with the `git init` command.
Create a docker-compose file with the following content as before, **make sure to stop the previously created containers**.

```yml
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

Add this file to the staging area and commit it:
```shell
git add docker-compose.yml
git commit -m "Initial commit"
```

```log
[master (root-commit) 4a99ad5] Initial commit
```

We would like to create a script, that will be copied to the git hook's directory, and it will be launched at every branch checkout.

The script must be made with the name `post-checkout` and it must be copied to the `.git/hooks` folder, and execute permission must be given to it, so invoke `chmod +x .git/hooks/post-checkout`

From the official documentation we can see that 3 parameters are going to given to that upon execution: https://git-scm.com/docs/githooks#_post_checkout

- $1 - Previous HEAD
- $2 - New HEAD
- $3 - 1 if checking out a branch, 0 if checking out something else, such as a file (rollbacks)

So we are going to receive the SHA values of the HEAD commit, rather than the branch names we are looking forward.

Let's add some code into the shell script:
```shell
#!/usr/bin/env bash

echo "Previous head:" $1
echo "Current head:" $2
echo "Branch checkout:" $3

```

After that create a new branch with the checkout or switch command: `git checkout -b test-branch`
```log
Switched to a new branch 'test-branch'
Previous head: 4a99ad545a28e22b5774ae2fa90040fdc86e4b7a
Current head: 4a99ad545a28e22b5774ae2fa90040fdc86e4b7a
Branch checkout: 1
```

We can immediately see one of the problem, if we would use those variables for the project name it would be super confusing, these SHA values are meaning nothing to the developer, and they can be the same if you start a new branch, so we have to come up with a better solution.

With the following command you can get the name of the current branch: `git branch --show-current` (Available in [Git 2.22.0](https://git-scm.com/docs/git-branch/2.22.0#Documentation/git-branch.txt---show-current)) - For earlier versions it is tricky, but this must be working: `git rev-parse --abbrev-ref HEAD`
```log
test-branch
```

Cool we are able to determine the branch we are on, but how can we identify the branch we are coming from?

So in theory we would like to **STOP** the containers from the branch we are switching from and **START** new containers.

I would like to propose two ways:
- We use the `git name-rev --name-only <sha>` command to retrieve it from the $1 argument
- We save the current branch name (in this case the previous branch) to a file named **.git/earlier-branch**, and then we would use it in the process

```shell
#!/usr/bin/env bash
if [ ! -f ".git/earlier-branch" ]; then
    echo "File: .git/earlier-branch does not exist, creating with current branch"
    echo EARLIER_BRANCH=$(git branch --show-current) > .git/earlier-branch
fi

echo "Loading: .git/earlier-branch"
source .git/earlier-branch
UPCOMING_BRANCH=$(git branch --show-current)

echo "Before switch branch: $EARLIER_BRANCH - Upcoming branch: $UPCOMING_BRANCH"
echo EARLIER_BRANCH=$(git branch --show-current) > .git/earlier-branch
```

This snippet on the first launch will create the file that will have a variable named **EARLIER_BRANCH** having value of the `$(git branch --show-current)` result. It may fail on the first try, but after it will be relatively consistent.

Okay, the 3rd parameter describes if this operation is a branch change or just a file checkout, so if it's value is **1 (one)** it means it is a branch "change", we have to check it.

Let's add the `docker-compose` commands into the script.
```shell
#!/usr/bin/env bash
echo "Post checkout starting"

#
# Args passed to this are:
# $1 - Previous HEAD
# $2 - New HEAD
# $3 - 1 if checking out a branch, 0 if checking out something else, such as a file (rollbacks)
#
if [ '1' == $3 ]
then
    if [ ! -f ".git/earlier-branch" ]; then
        echo "File: .git/earlier-branch does not exist, creating with current branch"
        echo EARLIER_BRANCH=$(git branch --show-current) > .git/earlier-branch
    fi

    echo "Loading: .git/earlier-branch"
    source .git/earlier-branch
    UPCOMING_BRANCH=$(git branch --show-current)

    echo "Before switch branch: $EARLIER_BRANCH - Upcoming branch: $UPCOMING_BRANCH"

    docker-compose --project-name=warp-$EARLIER_BRANCH stop
    docker-compose --project-name=warp-$UPCOMING_BRANCH up -d

    echo EARLIER_BRANCH=$(git branch --show-current) > .git/earlier-branch
fi
```

We are on the **test-branch** now, let's go back to the master: `git checkout master`

```log
Switched to branch 'master'
Post checkout starting
File: .git/earlier-branch does not exist, creating with current branch
Loading: .git/earlier-branch
Before switch branch: master - Upcoming branch: master
Creating warp-master_postgres-db_1 ... done
```

We can see the interference in the power: "Before switch branch: master - Upcoming branch: master" - This is not true, and this is the problem with this branch resolving strategy, the very first time it will not work, because the **.git/earlier-branch** file does not exist, but it can be created by hand on the clone, or with some other script.

Now if we would run the `docker ps` we should see the following:

```log
CONTAINER ID   IMAGE        COMMAND                  CREATED         STATUS                 PORTS                                     NAMES
674ca666fe1c   postgres:14  "docker-entrypoint.s…"   2 minutes ago   Up About a minute      0.0.0.0:5432->5432/tcp, :::5432->5432/tcp warp-master_postgres-db_1
```

The name of the container is **warp-master_postgres-db_1**, which we wanted! Yes!!!

Now let's switch back to the **test-branch** or create a brand new one, like we mentioned earlier above: `git checkout -b feature/ABC-1123-User-profile-management`

```log
Switched to a new branch 'feature/ABC-1123-User-profile-management'
Post checkout starting
Loading: .git/earlier-branch
Before switch branch: master - Upcoming branch: feature/ABC-1123-User-profile-management
Stopping warp-master_postgres-db_1 ... done
Creating network "warp-featureabc-1123-user-profile-management_default" with the default driver
Creating warp-featureabc-1123-user-profile-management_postgres-db_1 ... done
```

We can see that the **warp-master_postgres-db_1** container is being stopped, and after that the `warp-featureabc-1123-user-profile-management_postgres-db_1` container is being created. Awesome! This is what we wanted.


## Improve the experience

Me personally if I check out a project and I see a **docker-compose.yml** file I check it and start it from the IntelliJ IDEA after I imported the project. But there are other people who prefer to start it from the terminal with the `docker-compose` executable, which is totally understandable. With these methods the created git hook will not work properly so I propose to create a few helper scripts which can be used from the terminal and the hook also can depend on it.

Let's create a **start-infrastructure.sh** that will contain the following:
```shell
#!/usr/bin/env bash

GIT_BRANCH=${1:-$(git branch --show-current)}
NAME="warp-$GIT_BRANCH"
echo "Starting docker compose project with name: $NAME"
docker-compose --project-name=$NAME up -d
```

And let's create a **stop-infrastructure.sh** that will contain the following lines:
```shell
#!/usr/bin/env bash

GIT_BRANCH=${1:-$(git branch --show-current)}
NAME="warp-$GIT_BRANCH"
echo "Stopping docker compose project with name: $NAME"
docker-compose --project-name=$NAME stop
```

These scripts can be used to start and stop the containers, and they can be parametrized, but if no parameters are given to it, the current git branch will be used.

Let's rework the git hook:
```shell
#!/usr/bin/env bash
echo "Post checkout starting"

#
# Args passed to this are:
# $1 - Previous HEAD
# $2 - New HEAD
# $3 - 1 if checking out a branch, 0 if checking out something else, such as a file (rollbacks)
#
if [ '1' == $3 ]
then
    if [ ! -f ".git/earlier-branch" ]; then
        echo "File: .git/earlier-branch does not exist, creating with current branch"
        echo EARLIER_BRANCH=$(git branch --show-current) > .git/earlier-branch
    fi

    echo "Loading: .git/earlier-branch"
    source .git/earlier-branch
    UPCOMING_BRANCH=$(git branch --show-current)

    echo "Before switch branch: $EARLIER_BRANCH - Upcoming branch: $UPCOMING_BRANCH"

    ./stop-infrastructure.sh $EARLIER_BRANCH # Changed lines
    ./start-infrastructure.sh $UPCOMING_BRANCH  # Changed lines

    echo EARLIER_BRANCH=$(git branch --show-current) > .git/earlier-branch
fi
```

## Combine it with Maven

To make sure every developer on the project is having the same boost for their workflows we can use a Maven plugin to copy this script to their **.git/hooks** folder.

Create a folder named **hooks** and put the **post-checkout** file into, after that configure the following Maven plugin in your project:
```xml
<build>
        <plugins>
            <plugin>
                <groupId>com.rudikershaw.gitbuildhook</groupId>
                <artifactId>git-build-hook-maven-plugin</artifactId>
                <version>3.3.0</version>
                <configuration>
                    <installHooks>
                        <post-checkout>hooks/post-checkout</post-checkout>
                    </installHooks>
                </configuration>
                <executions>
                    <execution>
                        <id>install-hooks</id>
                        <phase>initialize</phase>
                        <goals>
                            <goal>install</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
</build>
```

To make sure that the created scripts are going to be executable for other developers as well, we have to add the execution permission to all via a Git command (**but first add them to the staging area**):
- `git add hooks/post-checkout start-infrastructure.sh stop-infrastructure.sh`
- `git update-index --chmod=+x hooks/post-checkout`
- `git update-index --chmod=+x start-infrastructure.sh`
- `git update-index --chmod=+x stop-infrastructure.sh` 

## Conclusion

Maybe this was a "long" journey, but I hope you liked it, I'm still experimenting with this setup, because you may not want to create a new environment for all of your new branches, but if that is the case, I think it is a good start.

One more addition could be introduced, when a local branch is being deleted maybe a cleanup script could be executed to delete the "dangling" docker-compose projects.

I'm curious about your opinion on the topic, have you tried to do the same? Do you know a better/more professional approach to the problem? If yes please let me know down in the comments.

If you want to follow me you can do it on the following places:
- [GitHub](https://github.com/nandorholozsnyak)
- [Twitter](https://twitter.com/TheRealHNK)
- [LinkedIn](https://www.linkedin.com/in/nandor-holozsnyak/)
