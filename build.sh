#!/bin/bash

# Environment variables
# PRIMARYPATH=$GOPATH/src/github.com/project-flogo/microgateway
PRIMARYPATH=$GOPATH/src/github.com/LakshmiMekala/microgateway
source ./sanity.sh
# go test ./... -v 2> >(tee gotest_stderr_file) | tee gotest_stdout_file
# Generate html report for go tests
go-test-html gotest_stdout_file gotest_stderr_file go-test-result.html



GITREPO="${TRAVIS_REPO_SLUG}"
GITREPONAME=${GITREPO:14}

#Auto detect build environment to LOCAL or TRAVIS
common::detect() {
    local BUILD_CICD="LOCAL" # default CICD
    if [[ ( -n "${TRAVIS}" ) && ( "${TRAVIS}" == "true" ) ]]; then
      BUILD_CICD="TRAVIS"
    fi
    echo "${BUILD_CICD}"
  
}

if [[ $(common::detect) == LOCAL ]]; then
    DESTDIR=artifacts
    mkdir -p artifacts   
    generate::sanity::report
else
# login to AWS s3
    artifact::directory
    mkdir ${HOME}/.aws
cat > ${HOME}/.aws/credentials <<EOL
[default]
aws_access_key_id = ${SITE_KEY}
aws_secret_access_key = ${SITE_KEY_SECRET}
EOL
fi
function artifact::directory()
{
    # Creating destination directory to publish artifacts
    mkdir -p artifacts/${TRAVIS_BRANCH}
    cd artifacts/${TRAVIS_BRANCH} ;
    if [ -n "${TRAVIS_TAG}" ]; then
        DESTDIR="$GITREPONAME-${TRAVIS_TAG}"
    elif [ -z "${TRAVIS_TAG}" ]; then
        DESTDIR="$GITREPONAME-${TRAVIS_BUILD_NUMBER}"
    fi

    if [ ! -d $DESTDIR ]; then
        mkdir $DESTDIR latest;
    fi
    echo "Creating folder - $DESTDIR /"    
}

function upload::artifacts() {
    pushd $PRIMARYPATH
    if [[ $(common::detect) == TRAVIS ]]; then
        cp go-test-result.html $DESTDIR
        cp $GOPATH/$FILENAME $DESTDIR
        cp go-test-result.html latest
        cp $GOPATH/$FILENAME latest
        # aws sw cp $PRIMARYPATH/artifacts "s3://$AWS_BUCKET/TIBCOSoftware/mashling" --recursive
    else
        cp go-test-result.html $DESTDIR
        cp $GOPATH/$FILENAME $DESTDIR
    fi
    popd
}

# Upload artifacts
upload::artifacts