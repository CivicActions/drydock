pipeline {
    agent none
    stages {
        stage('Build images') {
            agent any
            steps {
                script {
                    def drupal_acquia_mysql = docker.build("civicactions/drupal-acquia-mysql", "drupal/acquia/mysql")
                    def drupal_acquia_php_fpm_7_1 = docker.build("civicactions/drupal-acquia-php-fpm-7-1", "drupal/acquia/php-fpm-7.1")
                }
            }
        }
    }
}