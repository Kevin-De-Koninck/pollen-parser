# The base image is only used for build-dev (see last step)
FROM python:3.8.1-buster AS base
RUN apt-get update && \
    apt-get install -y --no-install-recommends vim netcat && \
    rm -rf /var/lib/apt/lists/*

# The builder image contains all required development tools
#FROM debian:buster-slim AS builder  # build-prod
#FROM python:3.8.1-buster AS builder  # build-dev
FROM {BUILDER} AS builder
RUN apt-get update && apt-get install -y --no-install-recommends --yes python3-venv gcc libpython3-dev && \
    python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip

# Populate the virtual environment in builder-venv-tests with all tools and tools for testing
FROM builder AS builder-venv-tests
COPY requirements_tests.txt /requirements_tests.txt
COPY requirements.txt /requirements.txt
RUN /venv/bin/pip install -r /requirements_tests.txt -r /requirements.txt

# Populate the virtual environment in builder-venv with only tools required for the application
FROM builder AS builder-venv
COPY requirements.txt /requirements.txt
RUN /venv/bin/pip install -r /requirements.txt

# Copy the entire repository and run all pytests in the tester image
FROM builder-venv-tests AS tester
COPY . /app
WORKDIR /app
RUN touch /app/coverage.xml
#START_TESTS_MARKER
RUN echo "\033[0;34m\n*** RUNNING PYTEST NOW...\033[0m\n"
RUN /venv/bin/pytest
RUN echo "\033[0;34m\n*** RUNNING PYLINT NOW...\033[0m\n"
RUN /venv/bin/pylint --rcfile=setup.cfg **/*.py
RUN echo "\033[0;34m\n*** RUNNING FLAKE8 NOW...\033[0m\n"
RUN /venv/bin/flake8
RUN echo "\033[0;34m\n*** RUNNING BANDIT NOW...\033[0m\n"
RUN /venv/bin/bandit -r --ini setup.cfg
#END_TESTS_MARKER

# From our base image, copy the artifacts from previous stages (virtual env and app)
#FROM gcr.io/distroless/python3-debian10 AS runner  # build-prod
#FROM base AS runner  # build-dev
FROM {RUNNER} AS runner
COPY --from=builder-venv /venv /venv
COPY --from=tester /app/boilerplate /app/boilerplate
COPY --from=tester /app/coverage.xml /app/coverage.xml
#ENVIRONMENT_VARS
#MOUNT_POINTS
#EXPOSED_PORTS
WORKDIR /app
ENTRYPOINT ["/venv/bin/python3", "-m", "boilerplate"]
USER {USER}
LABEL name={NAME}
LABEL version={VERSION}

