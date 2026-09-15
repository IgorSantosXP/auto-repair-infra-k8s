# Bootstrap do estado remoto

O backend S3 não pode provisionar a si mesmo. Estes recursos foram criados uma
única vez, fora do Terraform, e são pré-requisito para `terraform init` em
qualquer um dos quatro repositórios.

```bash
export AWS_PROFILE=auto-repair
BUCKET=auto-repair-tfstate-814623398856

aws s3api create-bucket --bucket "$BUCKET" --region us-east-1

aws s3api put-bucket-versioning --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption --bucket "$BUCKET" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"},"BucketKeyEnabled":true}]}'

aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  'BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true'
```

O lock de estado usa o mecanismo nativo do S3 (`use_lockfile = true`, Terraform
1.10+), dispensando a tabela DynamoDB do padrão antigo.

## Alarme de custo

```bash
aws budgets create-budget --account-id 814623398856 \
  --budget file://budget.json \
  --notifications-with-subscribers file://notifications.json
```

Orçamento mensal de US$ 10 com alertas em 50%, 80%, 100% e 100% previsto.
