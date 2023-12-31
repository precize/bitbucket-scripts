#!/bin/bash

wget -q -O - https://precize-terraform-context.s3.amazonaws.com/precize-context.tgz | tar -xvz -C /tmp
changedDirs=$(git log -m -1 --name-only --pretty="format:" ${BITBUCKET_COMMIT} | grep -vw 'bitbucket-pipelines.yml' | sed '/^[[:space:]]*$/d' | xargs dirname | sort -u)
dirArr=($changedDirs)

for dir in "${dirArr[@]}"
do
    /tmp/precize-context tag -d $dir --tag-groups git --skip-tags git_org,git_modifiers,git_last_modified_by,git_last_modified_at --parsers Terraform --tag-prefix precize_ --tag-local-modules false
done

lines=$(git status -s -uno | wc -l)
if [ $lines -gt 0 ];then
    git config --global user.name "Precize"
    git config --global user.email "noreply@precize.ai"
    git commit -am "Resource tags updated for Terraform configurations by Precize"
    git push
fi
