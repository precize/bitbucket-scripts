#!/bin/bash

export YOR_VERSION=0.1.183
wget -q -O - https://github.com/bridgecrewio/yor/releases/download/${YOR_VERSION}/yor_${YOR_VERSION}_linux_amd64.tar.gz | tar -xvz -C /tmp
changedDirs=$(git log -m -1 --name-only --pretty="format:" ${BITBUCKET_COMMIT} | grep -vw 'bitbucket-pipelines.yml' | sed '/^[[:space:]]*$/d' | xargs dirname | sort -u)
dirArr=($changedDirs)

for dir in "${dirArr[@]}"
do
    /tmp/yor tag -d $dir --tag-groups git --skip-tags git_org,git_modifiers,git_last_modified_by,git_last_modified_at --parsers Terraform --tag-local-modules false
done

lines=$(git status -s -uno | wc -l)
if [ $lines -gt 0 ];then
    git config --global user.name "Precize"
    git config --global user.email "noreply@precize.ai"
    git commit -am "Resource tags updated for Terraform configurations by Precize"
    git push
fi
