# Drydock

Library of Docker application templates following a common pattern.

## What is the Drydock Pattern

### All images

* Updated regularly
* Built and tested automatically
* Have strong code quality standards
* Work in both sandbox and CI environments
* Agnostic to sandbox tools - can work with Docker Compose or something else
* Agnostic to CI server/tool selection
* Support "exposed commands" to make Dockerized commands discoverable and avoid running non-container based dev/build tools
* Can be built on (using FROM) or can be extracted and customized fully
* Uses environment variables for configuration
* Standardized mount-points and environment variables for each application
* Use "lazy load" bootstrapping to make it easy to trigger build or import processes
* Support build processes that bundle database/indexes to make it fast and easy to spin up sandboxes and reset CI environments
* Reduce friction working with PaaS hosting environments by providing highly accurate reproductions

### Production images

* Support immutable deployment patterns - final image build as part of CI pipeline and can run in full read-only mode
* Compatible - image tests include full application automated tests and platform validation checks
* Secure:
  * Start from only trusted images, pin versions for images and key packages
  * Hardened to USGCB via STIG and scanned for compliance
  * NIST 800.53 compliance documented in OpenControl format
  * Processes run as non-root user
* Optimized for running in Kubernetes environments:
  * Supports "retry/crash on connection fail" service start-up
  * Provides health check endpoints
  * Provides Prometheus metric exporter
  * Keep images as small as possible (e.g. by using multi-stage builds)
  * Supports containerized persistent state (e.g. clustered databases managed via operators) or externalized storage (e.g. RDS)

### CI images

* Adhere to the following API:
* Exit code zero *must mean all tests pass*: exit code must be non-zero in any other case
  * In the case of tools where some level of failure is expected (e.g. linting a large legacy codebase) a `FAILLIMIT` environment variable can be accepted to set an acceptable baseline number of fails/errors/warnings, which can be reduced over time.
* Generally a separate image for each testing tool (except for unit tests and language linters) is desirable
  * Images should set the entrypoint to execute the test tool command (typically via a script wrapper), unless the tool comprises multiple top level commands
  * The test tool command(s) should have labels to expose them to sandbox environments
  * When provided with the docker command `autotest` the standard test suite should be run (encapsulating any parameters that should be set for CI usage)
* Test configuration/scripts must be copied or mounted at `/src`
* Functional web tests must support a configurable `TARGET` environment variable that specifies the base URL to test with no trailing slash (including proto and path prefix - e.g. `https://web/app/base`). Entrypoints may parse the hostname etc out if needed.
  * The default value of this environment variable should be `http://web`.
  * Web testing tools that check pages (e.g. security or accessibility scanners) can optionally use a newline delimited list of paths to test (e.g. `section/subsection/page`). If used, this file must be mounted at `/src/pages.txt`. If not used the scanner may default to just scanning the front page, or a spidering mode.
* Source code analyzers must scan code copied or mounted at `/target`
* Any results (test report, screenshots, coverage etc) should be output to the /results directory
  * Unit tests and language linters are run in the same image as the application code they are testing, so don't need to support /target, but should support output to /results
* The tool must either use an official vendor provided Docker image base, or be based on a hardened image
* The `/src` and `/target` directories must be mounted read only
* An example `docker-compose.<toolname>.yml` should be provided that demonstrates usage
* Base image testing:
  * The images should include an initial configuration copied to the `/src` directory (and a stub file in `/target` if required) that completes a basic smoke test
  * A sample web page will be provided at http://web for base image testing
