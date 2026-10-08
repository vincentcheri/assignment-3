# assignment-3

A small Bash-based DevOps utility with local validation, automated tests, and Docker smoke tests. GitHub Actions runs the same checks on pushes and pull requests; there is no cloud deployment.

## Commands

```text
./app/app.sh system-info
./app/app.sh check-host <host>
./app/app.sh check-port <host> <port>
./app/app.sh help
```

Invalid commands or arguments exit with status `2`. A host that cannot be resolved or a TCP connection that cannot be opened exits with status `1`.

## Local checks

```sh
./scripts/lint.sh
./tests/test.sh
./scripts/build.sh
```

Build and run the container directly:

```sh
docker build -t devops-tool .
docker run --rm devops-tool help
docker run --rm devops-tool system-info
```

`docker compose run --rm app system-info` is also available.

## CI failure demonstration

The workflow has three ordered jobs: `validate`, `test`, and `docker`. To demonstrate failure handling, push a temporary syntax error on a branch and confirm `validate` fails; then fix it and push again. The final workflow run should pass all three jobs.
