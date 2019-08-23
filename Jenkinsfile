pipeline {
    agent any
    environment { 
        PREFIX = 'civicactions/drydock-'
        TAG = "${env.BRANCH_NAME}"
    }
    stages {
        stage('Code linting') {
            steps {
                script {
                    // Output environment for debugging
                    sh 'export'
                    // Check bash script formatting
                    sh 'find * -name *.sh -print0 | xargs -n1 -I "{}" -0 docker run -i -v "$(pwd)":/workdir -w /workdir unibeautify/beautysh --files "/workdir/{}"'
                    // Can't check exit code, so just test if files changed on disk
                    sh 'if ! git diff-index --quiet HEAD --; then echo "Bash not matching beautysh style"; exit 1; fi'
                    // Lint bash scripts using shellcheck
                    sh 'find * -name *.sh -print0 | xargs -n1 -I "{}" -0 docker run -i --rm -v "$PWD":/src  koalaman/shellcheck "/src/{}"'
                    // Lint Dockerfiles using hadolint
                    sh 'find * -name Dockerfile* -print0 | xargs -n1 -I "{}" -0 docker run -i --rm -v "$PWD":/src hadolint/hadolint hadolint "/src/{}"'
                }
            }
        }
        stage('Run builds') {
            steps {
                script {
                    sh 'habitus -keep-all -f build-core.yml'
                }
            }
        }
        stage('Run RHEL 7 builds') {
            agent { 
                label 'rhel-7-latest-docker'
            }
            steps {
                script {
                    sh 'sudo tar czf subscriptions.tar.gz /etc/yum.repos.d/rh-cloud.repo /etc/pki/rhui/'
                    sh 'habitus -keep-all --binding=172.17.0.1 --secrets=true -f build-rhel.yml'
                }
            }
        }
        stage('OpenSCAP Scans') {
            steps {
                script {
                    // TODO: Identify the images to scan by filtering Docker images by label.
                    sh 'docker run --rm -i -v /var/run/docker.sock:/var/run/docker.sock "${PREFIX}security-openscap7-centos:${TAG}" auto "${PREFIX}baseline7-centos-disa:${TAG}"'
                    sh 'docker run --rm -i -v /var/run/docker.sock:/var/run/docker.sock "${PREFIX}security-openscap7-centos:${TAG}" auto "${PREFIX}baseline7-centos-usgcb:${TAG}"'
                }
            }
        }
    }
}
