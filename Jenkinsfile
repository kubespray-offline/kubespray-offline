@Library('pipelinex@development') _

def buildContainer(distro, tag) {
    docker_file = "Dockerfile_${distro}"
    image_name = "devops/${distro}_kubespray_builder:${tag}"
    common.shell(['docker', 'build', '-t', image_name, '-f', docker_file, '.'])
} // Closes function definition

def runContainer(distro, tag) {
    image_name = "devops/${distro}_kubespray_builder:${tag}"
    sh "docker run --net=host -v \$(pwd)/${distro}_outputs:/outputs -v /var/run/docker.sock:/var/run/docker.sock ${image_name} || exit 1"
    common.shell(['docker', 'rm', '-f', image_name])
    common.shell(['docker', 'rmi', '-f', image_name])
} // Closes function definition

def startRegistry(tag) {
    sh "mkdir -p \$(pwd)/docker_registry"
    sh "sudo chown -R iguazio:iguazio \$(pwd)/docker_registry"
    sh 'docker rm -f $(docker ps -q --filter "name=k8s_registry_*") || true'
    sh "docker run --net=host -d -u 1000:1000 -v \$(pwd)/docker_registry:/var/lib/registry --name k8s_registry_${tag} registry:latest"
} // Closes function definition

def stopRegistry(tag) {
  sh "docker rm -f k8s_registry_${tag}"
} // Closes function definition

def config = common.get_config()

def props = [
        buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '30', numToKeepStr: '1000'))
    ]

if (config.cron.get(env.BRANCH_NAME)) {
    props.add(pipelineTriggers([cron(config.cron.get(env.BRANCH_NAME))]))
}

properties(props)

common.main {
    nodes.builder('tel-ad') {
        timestamps {

            stage('checkout') {
                sh "sudo rm -rf ${WORKSPACE}/*"
                final scm_vars = checkout scm

                env.kubespray_hash = scm_vars.GIT_COMMIT
                currentBuild.description = "branch ${env.BRANCH_NAME}, ${env.kubespray_hash}"
            }

            stage('apply pre-build igz patches and start registry') {
                dir('./') {
                    sh("igz_files/igz_prebuild_patch.sh")
		    startRegistry(env.kubespray_hash)
                } // closes dir
            } // closes stage

            stage('build') {
                try {
                    dir('./') {
                        parallel(
                            "build_rocky8": {
                                buildContainer('rocky8', env.kubespray_hash)
                                runContainer('rocky8', env.kubespray_hash)
                            },
                            "build_centos7": {
                             //   buildContainer('centos7', env.kubespray_hash)
                             //   runContainer('centos7', env.kubespray_hash)
                            }
                        ) // closes parallel list
                    } // closes dir
                } catch (Exception e) {
                    println "An error occurred: ${e.getMessage()}"
                    stopRegistry(env.kubespray_hash)
                    throw e // Rethrow the exception to mark the build as failed
                }
            } // closes stage

            stage('merge assets and build ansible container') {
                dir('./') {
		    stopRegistry(env.kubespray_hash)
		    sh("echo 'So here we are'")
		    sh("ls -la")
                    sh("mv rocky8_outputs/rpms rocky8_outputs/rocky8_rpms")
                    sh("mv centos7_outputs/rpms centos7_outputs/centos7_rpms")
		            sh("mv ./docker_registry rocky8_outputs/")
                    sh("rm -rf outputs")
                    sh("mv rocky8_outputs outputs")
                    sh("mv centos7_outputs/centos7_rpms outputs")
                    sh("igz_files/igz_build_ansible.sh")
                } // closes dir
            } // closes stage

            stage('upload assets') {
                parallel(
                    'upload_to_nas': {
                        def build_by_hash_dir = "/mnt/nas/build_by_hash/kubespray"
                        def nas_dir = "${build_by_hash_dir}/${env.kubespray_hash}/pkg/kubespray"
                        sh("if [ -d ${nas_dir} ]; then rm -rf ${nas_dir}; fi")
                        sh("mkdir -p ${nas_dir}")
                        sh("cp -r outputs ${nas_dir}/")
                    }, // closes upload_to_nas block
                    'upload_to_s3': {
                        def bucket = 'iguazio-versions'
                        def bucket_region = 'us-east-1'
                        common.upload_to_s3(bucket, bucket_region, 'outputs', "build_by_hash/kubespray/${env.kubespray_hash}/pkg/kubespray/outputs")
                    } // closes upload_to_s3 block
                ) // closes parallel list
            } // closes stage
        } // closes timestamps 
    } // closes builders
} // closes common.main
