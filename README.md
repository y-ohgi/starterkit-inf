starterkit-inf
---

[y-ohgi/starterkit](https://github.com/y-ohgi/starterkit) が前提になります。

# About
<img src="https://github.com/y-ohgi/starterkit-inf/blob/master/docs/architecture.png?raw=true" />  

# How to Start
## Fork
このリポジトリをForkして自身のOrganization配下に配置します。

## Terraformコンテナの立ち上げ
dockerでterraformを起動します。  
Terraformのバージョン差異を解決できればbrewでインストールでもtfenvを使用しても問題ありませんが、今回はバージョンを指定しやすく比較的誰の環境にも入っているであろうdockerを使用します。
```
$ docker run -v $HOME/.aws:/root/.aws -v `pwd`:/code -w /code --entrypoint=ash -it hashicorp/terraform:0.12.18
```

## 初期化処理
workspaceを使用して環境を分けているため、workspaceを作成します。デフォルトでは `stg` と `prd` の2種類用意しています。

```
# terraform init
# terraform workspace new stg
```

## 準備
Route53のホストゾーンにドメインを用意し、 `variables_<env>.tf` にの `domains` 使用するドメインを記載します。  
`domains` は `,` 区切りで複数のドメインを記載することが可能です。

## 実行
```
# terraform plan
# terraform apply
```

## 削除
```
# terraform destroy
```
