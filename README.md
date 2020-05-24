![Build and tests](https://github.com/Kevin-De-Koninck/python-project-template/workflows/Build%20and%20tests/badge.svg)
![Push Docker container](https://github.com/Kevin-De-Koninck/python-project-template/workflows/Push%20Docker%20container/badge.svg)

[![Maintainability](https://api.codeclimate.com/v1/badges/33686856d8577095210f/maintainability)](https://codeclimate.com/github/Kevin-De-Koninck/python-project-template/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/33686856d8577095210f/test_coverage)](https://codeclimate.com/github/Kevin-De-Koninck/python-project-template/test_coverage)

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=Kevin-De-Koninck_python-project-template&metric=alert_status)](https://sonarcloud.io/dashboard?id=Kevin-De-Koninck_python-project-template)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=Kevin-De-Koninck_python-project-template&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=Kevin-De-Koninck_python-project-template)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=Kevin-De-Koninck_python-project-template&metric=coverage)](https://sonarcloud.io/dashboard?id=Kevin-De-Koninck_python-project-template)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=Kevin-De-Koninck_python-project-template&metric=security_rating)](https://sonarcloud.io/dashboard?id=Kevin-De-Koninck_python-project-template)


# python-project-template

This repository can be used as a template for starting every Python project you'll ever make. The code will run inside a Docker container along with all tests. This makes sure that the requirements for the host development machine are minimal:

- Docker
- Bash

This project makes use of SonarCloud (and optionally CodeClimate) for the test coverage visualisation and the code quality checks.

The following sections explain how a new user can set up it's project, after forking this template on github.

# Table of Contents

- [Initializing the template](#initializing-the-template)
  * [Create a GitHub Access Token](#create-a-github-access-token)
    + [Create a repository secret for the GitHub token](#create-a-repository-secret-for-the-github-token)
  * [Setup SonarCloud](#setup-sonarcloud)
    + [Create a repository secret for the SonarCloud login](#create-a-repository-secret-for-the-sonarcloud-login)
  * [(optional) Setup CodeClimate](#optional-setup-codeclimate)
    + [Create a repository secret for the CodeClimate test Reporter ID](#create-a-repository-secret-for-the-codeclimate-test-reporter-id)
  * [Configure the project](#configure-the-project)
  * [Badges on the README.md file](#badges-on-the-readmemd-file)
- [Usage](#usage)
  * [Build script](#build-script)
  * [Run script](#run-script)
  * [Add dependencies](#add-dependencies)
  * [Update python code](#update-python-code)
  * [Add tests](#add-tests)
  * [Environment variables, port mappings and volume mappings](#environment-variables--port-mappings-and-volume-mappings)
  * [tags](#tags)
  * [Updating the template](#updating-the-template)

# Initializing the template

## Create a GitHub Access Token

To be able to push the Docker container image to the Docker registry on GitHub, we'll need to create a GitHub Access Token:

1. Open your GitHub Profile.
2. Settings.
3. Developer settings.
4. Personal Access Token.
5. New.
    - Note: GITHUB\_TOKEN used to push containers to the docker registry.
    - selected scopes:
        * repo (all)
        * write:packages
        * read:packages
        * delete:packages

A new token will be generated. Save this to a file on your local development machine (not inside a repo), e.g. `/Users/kevin/GH_TOKEN.txt`. Update this path insinde the file `config.ini` (key `GITHUB_TOKEN_FILE` under section `META`).

With this token, you should be able to log in into the remote Docker registry:

``` bash
cat /Users/kevin/GH_TOKEN.txt | docker login docker.pkg.github.com -u kevin-de-koninck --password-stdin
```

Github uses this setup:
```
https://github.com/OWNER/REPOSITORY/packages
```
In this case, it would be:
```
https://github.com/kevin-de-koninck/python-project-template/packages
```

### Create a repository secret for the GitHub token

We don't want to save the GitHub token as plain text in our repository. For this, we can use the ropsitory secrets. Add the Personal Access Token to your repository as follows (use the exact naming):

1. Open your repository on GitHub.
2. Go to 'settings'.
3. Go to 'secrets'.
4. Click on 'new secret'.
    - Name: REGISTRY_TOKEN
    - Value: __<Paste the token here>__
5. Click on 'Add secret'.

## Setup SonarCloud

1. Go to https://sonarcloud.io/projects/create
2. select your repository.
3. Click on 'set up'.
4. Under 'Choose another analysis method' select 'With other CI tools'.
5. Under 'What option best describes your build?' select 'Other (for JS, TS, Go, Python, PHP, ...).
6. Under 'What is your OS?' select 'Linux'.

You'll land on a page with some more information. Under section 'Execute the SonarScanner in the project's folder' you'll find a couple of key=value entries.
Open the file `sonar-project.properties` in this repository and update the values in that file with the values you found on your Sonarcloud page.

### Create a repository secret for the SonarCloud login

Lastly, we have to add the value of `Dsonar.login` (under section 'Dsonar.login') to the repository.
We don't want to save the login token as plain text in our repository. For this, we can use the repository secrets. Add the login secret to your repository as follows (use the exact naming): 

1. Open your repository on GitHub.
2. Go to 'settings'.
3. Go to 'secrets'.
4. Click on 'new secret'.
    - Name: SONAR_TOKEN
    - Value: __<Paste the Dsonar.login token here>__
5. Click on 'Add secret'.

## (optional) Setup CodeClimate

This is optional, since SonarCloud does the same things and more. To remove CodeClimate from the project, remove the following code from the `.github/workflows/build-test.yml` [file](https://github.com/Kevin-De-Koninck/python-project-template/blob/master/.github/workflows/build-test.yml#L66-L72):

``` yaml
    - name: Send report to CodeClimate
      run: |
        export GIT_BRANCH="${GITHUB_REF/refs\/heads\//}"
        curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > ./cc-test-reporter
        chmod +x ./cc-test-reporter
        ./cc-test-reporter format-coverage -t coverage.py coverage.xml
        ./cc-test-reporter upload-coverage -r "${{ secrets.CC_TEST_REPORTER_ID }}"
```

If you do want to keep using CodeClimate, Make sure you have an account on CodeClimate. If not, log in with your GitHub account on 'CodeClimate Quality': https://codeclimate.com/login/github/join 

1. Open your dashboard: https://codeclimate.com/oss/dashboard
2. Click on 'Add repository'.
3. Select your public repository and click on 'Add Repo'.
4. Click on 'Add Anyway'.
5. Open the dashboard again: https://codeclimate.com/oss/dashboard
6. Open your new repository.
7. Go to the tab 'Repo settings'.
8. Go to 'Test coverage'.
9. Copy the value of 'Test Reporter ID'.

### Create a repository secret for the CodeClimate test Reporter ID

Lastly, we have to add the value of `Test Reporter ID` to our repository.
We don't want to save the ID as plain text in our repository. For this, we can use the repository secrets. Add the ID to your repository as follows (use the exact naming): 

1. Open your repository on GitHub.
2. Go to 'settings'.
3. Go to 'secrets'.
4. Click on 'new secret'.
    - Name: CC_TEST_REPORTER_ID
    - Value: __<Paste the Test Reporter ID token here>__
5. Click on 'Add secret'.

## Configure the project

To configure the project, we first have to change the `config.ini` file.

1. open `config.ini`
2. Update the values under the 'META' section.
    - `REPO_OWNER`: The username on GitHub.
    - `MODULE_NAME`: The name of the Python module you'll develop.
    - `GITHUB_TOKEN_FILE`: The absolute path to the GitHub Personal Access Token file on your development machine.

Next, run the configure script:

``` bash
./configure.sh
``` 

This script will rename all files and all content of files to match the settings in the `config.ini` file. At the end, the script will create a new commit with all changes and sets a tag to the repository. Use the following commands to push everything:

``` bash
git push
git push origin --tags
```

If everything was successfull, you'll now have succeeding tests on [Github Actions](https://github.com/Kevin-De-Koninck/python-project-template/actions) and a Docker container image available on the [Docker registry](https://github.com/Kevin-De-Koninck/python-project-template/packages).

## Badges on the README.md file

The `configure.sh` script cannot change the badges on the top of the `README.md` file. These must be manually configured.

1. GitHub Action badges.
    - Open your repository.
    - Go to the tab 'Actions'.
    - Select a workflow.
    - Click on 'Create status badge'.
    - Click on 'Copy status badge Markdown'.
    - Paste the code in the `README.md` file.
2. Code climate maintainability and test coverage badges:
    - Open your project on CodeClimate.
    - Open the tab 'Repo settings'.
    - Click on 'Badges'.
    - Select 'Markdown' for the badge that you want.
    - Copy and paste the code in the `README.md` file.
3. Sonar Cloud Quality gate badge:
    - Open your project in SonarCloud.
    - Scroll down and on the right side click on 'Get project badges'.
    - Copy and paste the code in the `README.md` file.

# Usage

After initializing the project, it's time to use the project. The template provides 2 helper scripts:

- `build.sh`
- `run.sh`

The 2 following sections will explain the most basic usage. To see all the possibilities, use argument `-h` on each script.

## Build script

The build script can build 2 porjects, the dev project and the prod project:

- `dev`: This project creates a Docker container containing the python code, developement tools inside the container, a shell, ... This project is mainly used for developing.
- `prod`: This project creates a Docker container (distroless) containing the bare minimum to run the project. The container does not have a shell or any other development tool but its size is significantly smaller then the `dev` container. This project is used to push the Docker container image to the remote Docker registry.

During development, you'll usually want to build the development container. By default, when building the dev container, all tests will run and only if these succeed, a container image is created. This behavior can be skipped if required by using `--skip-tests`.

``` bash
# Build the development container and run all tests
./build.sh -p dev

# Build the production image with tag 'v0.0.1'
./build.sh -p prod -v 'v0.0.1'

# Clean the local Docker registry (remove our images locally)
./build.sh --clean
```

## Run script

After building (and testing) the Docker container, the container image will be available in the local Docker registry. Frome here, it is possible to run the container directly using the `run.sh` script. We can also open an interactive shell inside the container or run the container command with arguments.

``` bash
# Run the Docker container with no extra arguments provided to our Python module
./run.sh

# Run the Docker container and provide extra arguments to our Python module (pass parameter -p and -n to our module)
./run.sh -a command -c '-p 12345 -n test'

# Run an interactive shell inside the Docker container
./run.sh -b

# Run a specific version of the container (e.g. a production image)
./run.sh -v 'v0.0.1'

# Log in into the remote Docker registry
./run.sh -l
```

## Add dependencies

To add python dependencies (pip), this template provide 2 files:

- `requirements.txt`: Add all your pip dependencies here that the Python project uses.
- `requirements_tests.txt`: Add all your pip dependencies here that the test framework requires, bu is not needed to run the Python code.

## Update python code

in the root of the repo, you'll find a directory with the same name as the module name you specified in the `config.ini` file. This is the root of your Python code. Update everything in this directory regarding your project.

## Add tests

Tests are run with pytest and can be modified/added under the directory 'tests'.

## Environment variables, port mappings and volume mappings

The `config.ini` file can be used to set custom environment variables, mount points and port exposure inside the container. The following snippit of `config.ini` will:

- expose port 8000 inside the container and when we run the container with `run.sh` hostport 12345 will be mapped to port 8000 inside the container.
- Create a mount point '/app/template/extras' and when we run the container with `run.sh` host volume /Users/kevin/extras will be mounted inside the container.
- Envirment variable 'TEST_ENV' will be set containing the value 'test' inside the container.

``` ini
[ENVIRONMENT_VARS]
TEST_ENV=test

[VOLUME_MAPS]
/Users/kevin/extras=/app/template/extras

[PORT_MAPS]
12345=8000
```

## tags

when a tag has been added to the master branch, a GitHub actions job will be triggerd that builds the production image and pushes it to the remote Docker registry. To add a tag, use the following code:

```
git tag -a v0.0.2 -m "First draft for Github action 'push'"
git push origin --tags
```

## Updating the template

If it is required to pull new updates made to the template repository, use the following method:

``` bash
# Add the remote, call it template
git remote add template https://github.com/Kevin-De-Koninck/python-project-template.git

# Get everyting from the remote
git fetch template

Make sure that you're on your master branch
git checkout master

# Rewrite your master branch so that any commits of yours that aren't already in template/master are replayed on top of that other branch
git rebase template/master

# Fix any rebase issues

# Force-push to your repo
git push --force-with-lease origin master

# Remove the remote again
git remote remove template
```

