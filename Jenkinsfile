#!groovy

node {
    stage('Checkout') {
        checkout scm
    }

    stage('Clean') {
        make "clean"
        stash name: "sources"
    }
}

parallel (
    "build": {
        node {
            stage('Build') {
                deleteDir()
                unstash "sources"
                make "once"
                stash name: "built"
                archiveArtifacts 'main.pdf'
            }
        }
    },
)

//Run gradle
void make(def args) {
    if (isUnix()) {
        sh "make ${args}"
    } else {
        bat "make ${args}"
    }
}

