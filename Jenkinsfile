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
                    sh 'find * -name *.sh -print0 | xargs -n1 -I "{}" -0 docker run -i -v "$(pwd)":/workdir -w /workdir -e PHP_CS_FIXER_IGNORE_ENV=1 unibeautify/beautysh --files "/workdir/{}"'
                    // Can't check exit code, so just test if files changed on disk
                    sh 'if ! git diff-index --quiet HEAD --; then echo "Bash not matching beautysh style"; exit 1; fi'
                    // Lint bash scripts using shellcheck
                    sh 'find * -name *.sh -print0 | xargs -n1 -I "{}" -0 docker run -i --rm -v "$PWD":/src  koalaman/shellcheck "/src/{}"'
                    // Lint Dockerfiles using hadolint
                    sh 'find * -name Dockerfile* -print0 | xargs -n1 -I "{}" -0 docker run -i --rm -v "$PWD":/src hadolint/hadolint hadolint "/src/{}"'
                    // Lint PHP using php-cs-fixer
                    sh 'docker run -i -v "$(pwd)":/workdir -w /workdir -e PHP_CS_FIXER_IGNORE_ENV=1 unibeautify/php-cs-fixer fix -v --dry-run --stop-on-violation --using-cache=no tools/getconfig.php'
                }
            }
        }
        stage('Run builds') {
            steps {
                script {
                    sh 'habitus'
                }
            }
        }
        stage('Test Acquia PHP 7.1 image') {
            steps {
                script {
                    dir('drupal/acquia') { 
                        withEnv(['VERSION=7.1']) {
                            sh '../test/test.sh'
                        }
                    }
                }
            }
        }
        stage('Test Acquia PHP 7.2 image') {
            steps {
                script {
                    dir('drupal/acquia') { 
                        withEnv(['VERSION=7.2']) {
                            sh '../test/test.sh'
                        }
                    }
                }
            }
        }
        stage('Test Pantheon PHP 7.1 image') {
            steps {
                script {
                    dir('drupal/pantheon') { 
                        withEnv(['VERSION=7.1']) {
                            sh '../test/test.sh'
                        }
                    }
                }
            }
        }
        stage('Test Pantheon PHP 7.2 image') {
            steps {
                script {
                    dir('drupal/pantheon') { 
                        withEnv(['VERSION=7.2']) {
                            sh '../test/test.sh'
                        }
                    }
                }
            }
        }
    }
}
