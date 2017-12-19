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
    "lint": {
        node {
            stage('Lint') {
                deleteDir()
                unstash "sources"
                make "lint"
                stash name: "linted"
                archiveArtifacts 'chktex.txt'
                archiveArtifacts 'biblatexcheck.html'
            }
        }
    }
)

//Run gradle
void make(def args) {
    if (isUnix()) {
        sh "make ${args}"
    } else {
        bat "make ${args}"
    }
}

