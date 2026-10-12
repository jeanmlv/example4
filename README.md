# example4


import os
import subprocess
from getpass import getpass

SOURCE = "s3://med-ai-clinical/cnto1959uco3001_kc_lte_w188/"
DEST = (
    "/domino/datasets/local/clinical-trial-data/"
    "CNTO1959UCO3001-QUASAR-LTE-WK188/"
)

print("QUASAR LTE-W188 - Med.AI S3 to Domino")
print("Copie cada credencial do Med.AI antes de preencher seu campo.")

access_key = getpass("Access Key ID: ")
secret_key = getpass("Secret Access Key: ")
session_token = getpass("Session Token: ")

if not all([access_key, secret_key, session_token]):
    raise SystemExit("Erro: uma ou mais credenciais estao vazias.")

env = os.environ.copy()
env.update({
    "AWS_ACCESS_KEY_ID": access_key,
    "AWS_SECRET_ACCESS_KEY": secret_key,
    "AWS_SESSION_TOKEN": session_token,
    "AWS_DEFAULT_REGION": "us-east-1",
})

del access_key, secret_key, session_token

print("\nVerificando acesso ao S3...")

result = subprocess.run(
    ["aws", "s3", "ls", SOURCE],
    env=env,
    check=False
)

if result.returncode != 0:
    raise SystemExit("Falha no acesso ao S3. Verifique as credenciais.")

print("\nSimulando transferencia (dry-run)...")

result = subprocess.run(
    ["aws", "s3", "sync", SOURCE, DEST, "--dryrun"],
    env=env,
    check=False
)

if result.returncode != 0:
    raise SystemExit("Falha na simulacao. Nenhum arquivo foi transferido.")

confirm = input("\nDigite SIM para iniciar a transferencia: ").strip()

if confirm != "SIM":
    raise SystemExit("Transferencia cancelada.")

os.makedirs(DEST, exist_ok=True)

result = subprocess.run(
    ["aws", "s3", "sync", SOURCE, DEST, "--no-progress"],
    env=env,
    check=False
)

if result.returncode != 0:
    raise SystemExit("Transferencia apresentou erros. Verifique a saida.")

print("\nTransferencia concluida.")
print("Diretorio:", DEST)
print("Pastas encontradas:", os.listdir(DEST))



        
