#!/bin/bash

rm -rf .git
rm -rf .dvc
rm -rf dvclive
rm -rf .venv
rm .gitignore
rm .dvcignore
rm dvc.lock
rm dvc.yaml
rm params.yaml

set -uex

git init
python3 -m venv .venv
echo .venv >> .gitignore
source .venv/bin/activate
git add .gitignore

pip install 'dvc[s3]<3' dvclive
dvc init
export AWS_PROFILE=iterative-sandbox
dvc remote add --local named-remote-1 s3://dvc-public/remote/mixed-dvc-versions/named-remote-1
dvc remote add --local named-remote-2 s3://dvc-public/remote/mixed-dvc-versions/named-remote-2
dvc remote add named-remote-1 https://remote.dvc.org/mixed-dvc-versions/named-remote-1
dvc remote add named-remote-2 https://remote.dvc.org/mixed-dvc-versions/named-remote-2

git commit -m "init"

cat <<"EOF" > dvc.yaml
artifacts:
  nlp:
    path: model.pkl
    type: model
stages:
  train:
    cmd: python train.py ${epochs}
    metrics:
    - dvclive/metrics.json:
        remote: named-remote-1
    plots:
    - dvclive/plots:
        remote: named-remote-2
EOF

echo 'epochs: 3' > params.yaml
dvc repro
git add .
git commit -m "DVC 2"
dvc push

pip install 'dvc[s3]>=3'
echo 'epochs: 4' > params.yaml
dvc repro
git add .
git commit -m "DVC 3"
dvc push

