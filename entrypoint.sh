#!/usr/bin/env bash

set -euo pipefail

while getopts g:o:s: flag; do
  case "${flag}" in
    g)
      github_token=${OPTARG}
      ;;
    o)
      openshift_token=${OPTARG}
      ;;
    s)
      openshift_server=${OPTARG}
      ;;
    *)
      echo "invalid input"
      exit 1
      ;;
  esac
done

git config --global user.email "concaf@redhat.com"
git config --global user.name "paction-bot"

echo "logging into github..."
echo "$github_token" | gh auth login --with-token

echo "logging into openshift cluster at $openshift_server..."
oc login --token="$openshift_token" --server="$openshift_server" --insecure-skip-tls-verify=true

echo "cloning repo $GITHUB_REPOSITORY"
git clone "https://$github_token@github.com/$GITHUB_REPOSITORY" repo
cd repo
git checkout -b paction-branch

echo "running pac bootstrap..."
tkn pac bootstrap --skip-github-app
oc create ns paction-pipelines || true

echo "creating pac repo..."
tkn pac create repo --url "https://github.com/$GITHUB_REPOSITORY" --namespace paction-pipelines

git add .tekton/
git commit -m "PAC bootstrap by paction"

echo "pushing pac config to remote branch..."
git push origin paction-branch -f

echo "creating pr..."
gh pr create --fill
