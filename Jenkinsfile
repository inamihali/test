#!/usr/bin/env groovy

@Library("jarvis") _
node("jenkins-runner") {
    gazrPipeline {
        def alfred = getAlfred()
        def alfredImage = alfred.docker().getImages()[0]
        def alfredImageName = alfredImage.name
        def alfredImageArgs = alfredImage.build_args

        def gitCommitSha = getGitCommitHash()
        //def image = "quay.io/dailymotionadmin/${alfredImageName}"
        stage("Quality & SonarQube") {
	    sh "env"
	    println "Build from : " +  currentBuild.getBuildCauses()
            gazrTestUnit()
            scaleReleaseLint()
            codexSonarQube()
        }

        stage("docker build & push") {
            useDockerHost {
                for (image in alfred.docker().getImages()) {
                    docker.build("${image.name}:${gitCommitSha}", "${image.build_args}")
                    pushDockerImage(
                        "${image.name}:${gitCommitSha}",
                        [
                            branches_to_images: []
                        ]
                    )
                }
            }
        }

        // Check the pull-request target branch is correct
        if (env.BRANCH_NAME ==~ /^PR-\d+$/) {
            if (env.CHANGE_TARGET ==~ /(^master$)/) {
                env.BRANCH_NAME = "discovery-dev"
            }
        }

        if (env.BRANCH_NAME ==~ /(^discovery-dev$)|(^master$)|/) {
            stage("Deployment") {
                stepsScaleRelease()
            }
        }
    }
}
