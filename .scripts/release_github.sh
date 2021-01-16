#!/bin/bash
set -e

git fetch --tags
THIS_TAG=$(git describe --tags --abbrev=0)

BODY="{
      \"tag_name\": \"$THIS_TAG\",
      \"target_commitish\": \"master\",
      \"name\": \"$THIS_TAG\",
      \"body\": \" \"
  }"

# Create the release in GitHub and extract its id from the response
RESPONSE_BODY=$(curl -s \
  -v \
  -u "${CIRCLE_USERNAME}":"${GITHUB_TOKEN}" \
  --header "Accept: application/vnd.github.v3+json" \
  --header "Content-Type: application/json; charset=utf-8" \
  --request POST \
  --data "${BODY}" \
  https://api.github.com/repos/"${CIRCLE_PROJECT_USERNAME}"/"${CIRCLE_PROJECT_REPONAME}"/releases)

# Extract the upload_url value
UPLOAD_URL=$(echo "${RESPONSE_BODY}" | jq -r .upload_url)

cp library/build/outputs/aar/library-release.aar library.aar

# Attach library
LIBRARY_UPLOAD_URL="${UPLOAD_URL}//?name,label/?name=library-${THIS_TAG}.aar"
curl -s \
  -v \
  -u "${CIRCLE_USERNAME}":"${GITHUB_TOKEN}" \
  --header "Accept: application/vnd.github.v3+json" \
  --header "Content-Type: application/zip" \
  --data-binary "@library.aar" \
  --request POST \
  "${LIBRARY_UPLOAD_URL}"

cp sample/build/outputs/apk/debug/sample-debug.apk sample.apk

# Attach sample
SAMPLE_UPLOAD_URL="${UPLOAD_URL}//?name,label/?name=sample-${THIS_TAG}.apk"
curl -s \
  -v \
  -u "${CIRCLE_USERNAME}":"${GITHUB_TOKEN}" \
  --header "Accept: application/vnd.github.v3+json" \
  --header "Content-Type: application/zip" \
  --data-binary "@sample.apk" \
  --request POST \
  "${SAMPLE_UPLOAD_URL}"

echo "GitHub release complete."
