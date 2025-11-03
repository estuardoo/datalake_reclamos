# 🧠 Data Lake de Reclamos en AWS

Este repositorio contiene todo el código para desplegar automáticamente un Data Lake en AWS (S3 + Glue + Athena) desde GitHub o la consola local.

## 🚀 Despliegue desde GitHub Actions
1. En tu repo, ve a **Settings → Secrets → Actions** y agrega:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION` (ej. `sa-east-1`)

2. Ve a **Actions → Deploy Data Lake AWS → Run workflow** (o haz push a `main`).

✅ Esto creará los buckets, cargará `data/abc-reclamos-ml.csv` y registrará la tabla en Glue/Athena.

## 🧰 Despliegue manual con Terraform
```bash
cd terraform
terraform init
terraform apply -auto-approve
```

## 🔎 Consultas en Athena
```sql
SELECT * FROM datalake_db.reclamos_ml LIMIT 10;
```

> Puedes reemplazar `data/abc-reclamos-ml.csv` por tu dataset real y volver a aplicar Terraform para actualizar el objeto en S3.
