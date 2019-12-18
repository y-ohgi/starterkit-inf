starterkit-inf
---

[y-ohgi/starterkit](https://github.com/y-ohgi/starterkit) が前提になります。

# About
<img src="https://github.com/y-ohgi/starterkit-inf/blob/master/docs/architecture.png?raw=true" />  

# How to Start
## 1. Fork
このリポジトリをForkして自身のOrganization配下に配置します。

## 2. AWSの認証情報を取得
awsコマンドを使用して認証情報を取得します。
```
$ aws configure
AWS Access Key ID [None]: <YOUR ACCESS KEY>
AWS Secret Access Key [None]: <YOUR SECRET ACCESS KEY>
Default region name [None]: ap-northeast-1
Default output format [None]: json
```

## 3. backend用のS3バケットを作成
terraformのbackend（作成したリソースの状態）を管理するためのS3バケットを作成します。  
作成時に、オペミスでファイルを削除してしまった際の保険として、S3バケットのバージョニングも有効化します。

```
$ aws s3api create-bucket \
    --region ap-northeast-1 \
    --create-bucket-configuration LocationConstraint=ap-northeast-1 \
    --bucket <S3 BUCKET NAME>
$ aws s3 put-bucket-versioning \
    --versioning-configuration Status=Enabled \
    --bucket arn:aws:s3:::<S3 BUCKET NAME>
```

## 4. Terraformコンテナの立ち上げ
dockerでterraformを起動します。  

Terraformのバージョン差異を解決できればbrewでインストールでもtfenvを使用しても問題ありませんが、今回はバージョンを指定しやすく比較的誰の環境にも入っているであろうdockerを使用します。

```
$ docker run \
    -v $HOME/.aws:/root/.aws \
    -v `pwd`:/code \
    -w /code \
    -it \
    --entrypoint=ash \
    hashicorp/terraform:0.12.18
```

## 5. 初期化処理
workspaceを使用して環境（本番・ステージング等）の設定します。  
サンプルコードでは `prd` ・ `stg` の2環境用意しています。

```
# terraform init -backend-config="bucket=<S3 BUCKET NAME>"
# terraform workspace new <env>
```

## 6. 変数の編集
1. `variables.tf` の `name` を作成するプロダクトに合わせて命名します
    - `name = "${terraform.workspace}-<YOUR PRODUCT NAME>"` 
2. Route53のホストゾーンにドメインを用意し、 `variables_<env>.tf` の `domains` へ使用するドメインを記載します。  
    - `domains` は `,` 区切りで複数のドメインを記載することが可能です。

## 7. プロビジョニング
`plan` でdry-runを実行し、 `apply` でプロビジョニングを実施します。
```
# terraform plan
# terraform apply
```

## 8. 削除
プロビジョニングしたリソースは `destroy` で削除可能です。
```
# terraform destroy
```

# Tips
## 環境の追加
workspaceを追加し、 `variables.tf` の `workspaces` へ追加したworkspaceを記載します。  
次に、 `variables_<env>.tf` を作成し、他の環境同様の値を記載します。

```
# terraform workspace new dev
# vi variables.tf
# cp variables_stg.tf variables_dev.tf
# vi variables_dev.tf
# terraform apply
```

[State: Workspaces - Terraform by HashiCorp](https://www.terraform.io/docs/state/workspaces.html)

公式ではステージングやプロダクションのような環境の出し分けにworkspaceの使用を推奨されていませんが、当リポジトリでは環境差分は `variables_<env>.tf` で収まる範囲で環境差分が少ないことと、同一の `.tf` ファイル郡で `.tfstate` を環境毎に分けたいためworkspaceを使用します。

## AWS認証情報の切り替え
How to Startでは `aws configure` で生成したAWSの認証情報を利用していました。  
1アカウントであれば問題ないかもしれませんが、本番とステージングでアカウントを分けていたり、複数のAWSアカウントを管理していたり、IAMでアクションの制御をしていたり、認証情報を切り替えたいことが多々あると思います。  
その際は `profile` を使用するか、Docker起動時に以下のようにアクセスキー・シークレットアクセスキーを渡すことも可能です。

```
$ docker run \
    -e AWS_ACCESS_KEY_ID=<YOUR ACCESS KEY> \
    -e AWS_SECRET_ACCESS_KEY=<YOUR SECRET KEY> \
    -v `pwd`:/code \
    -w /code \
    -it \
    --entrypoint=ash \
    hashicorp/terraform:0.12.18
```

手段は問いませんが、カジュアルに本番環境をdestroyできないような運用をしましょう。

## コスト
月額（730hour）の計算になります、が、トラフィックによるところが大きいので実サービスで予測されるトラフィックをAWSが提供する簡易計算ツールで計算すると良いでしょう。

[AWS Pricing Calculator](https://calculator.aws/#/)

| リソース        | 金額       |
|-----------------|------------|
| VPC NAT gateway | 135.78 USD |
| ALB             | 23.58 USD  |
