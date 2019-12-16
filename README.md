# How to Start
```
$ docker run -v $HOME/.aws:/root/.aws -v `pwd`:/code -w /code --entrypoint=ash -it hashicorp/terraform:0.12.18
# terraform init
# terraform plan -var-file=variables/stg.tfvar
```
