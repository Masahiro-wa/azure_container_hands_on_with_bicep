import uuid
import re

def normalize_env_name(env_name: str) -> str:
    # 小文字に変換し、アルファベットと数字のみを残す
    return re.sub(r'[^a-z0-9]', '', env_name.lower())

def get_deployment_name(env_name: str, componet: str) -> str:
    return f"{env_name}-{componet}-deployment"

def get_main_rg_name(env_name: str) -> str:
    return f"{env_name}-main-rg"

def get_vnet_name(env_name: str) -> str:
    return f"{env_name}-vnet"

def get_dev_subnet_name(env_name: str) -> str:
    return f"{env_name}-dev-subnet"

def get_vm_nsg_name(env_name: str) -> str:
    return f"{env_name}-vm-nsg"

def get_dev_vm_name(env_name: str) -> str:
    return f"{env_name}-dev-vm"

def get_apps_container_env_name(env_name: str) -> str:
    return f"{env_name}-apps-container-env"

def get_vm_id_name(env_name: str) -> str:
    return f"{env_name}-vm-id"

def  get_backend_id_name(env_name: str) -> str:
    return f"{env_name}-backend-id"

def get_frontend_id_name(env_name: str) -> str:
    return f"{env_name}-frontend-id"

def get_log_analytics_name(env_name: str) -> str:
    return f"{env_name}-log-analytics"

def get_app_insights_name(env_name: str) -> str:
    return f"{env_name}-app-insights"

def get_containerapps_env_name(env_name: str) -> str:
    return f"{env_name}-containerapps-env"

def get_scheduler_id_name(env_name: str) -> str:
    return f"{env_name}-scheduler-id"

def get_acr_name_prefix(env_name: str) -> str:
    normalized_env_name = normalize_env_name(env_name)
    return f"{normalized_env_name}acr"

def get_unique_acr_name(env_name: str) -> str:
    prefix = get_acr_name_prefix(env_name)
    suffix = __get_unique_suffix()
    return f"{prefix}{suffix}"

def get_keyvault_name_prefix(env_name: str) -> str:
    normalized_env_name = normalize_env_name(env_name)
    return f"{normalized_env_name}kvt"

def get_unique_keyvault_name(env_name: str) -> str:
    prefix = get_keyvault_name_prefix(env_name)
    suffix = __get_unique_suffix()
    return f"{prefix}{suffix}"

def get_storage_account_name_prefix(env_name: str) -> str:
    normalized_env_name = normalize_env_name(env_name)
    return f"{normalized_env_name}stg"

def get_unique_storage_account_name(env_name: str) -> str:
    prefix = get_storage_account_name_prefix(env_name)
    suffix = __get_unique_suffix()
    return f"{prefix}{suffix}"

def get_sql_name_prefix(env_name: str) -> str:
    return f"{env_name}-sql"

def get_unique_sql_server_name(env_name: str) -> str:
    prefix = get_sql_name_prefix(env_name)
    suffix = __get_unique_suffix()
    return f"{prefix}-{suffix}"

def get_sql_secret_name(env_name: str) -> str:
    return f"{env_name}-sql-pass"

def get_vault_url(vault_name: str) -> str:
    return f"https://{vault_name}.vault.azure.net/"

def get_storage_account_url(account_name: str) -> str:
    return f"https://{account_name}.blob.core.windows.net"

def __get_unique_suffix() -> str:
    # UUIDを生成し、ハイフンを除去し、小文字に変換
    raw_suffix = str(uuid.uuid4()).replace('-', '').lower()
    # アルファベットと数字のみを抽出
    filtered_suffix = re.sub(r'[^a-z0-9]', '', raw_suffix)
    # 最初の8文字を返す
    return filtered_suffix[:8]
