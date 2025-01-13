from azure.mgmt.storage import StorageManagementClient
from azure.core.exceptions import HttpResponseError
from azure.storage.blob import BlobServiceClient
from .base import Base
from deploy.utils import context, log
import os

class StorageAccount(Base):
    def __init__(self, subscription_id):
        super().__init__(subscription_id)
        self._set_clients()
    
    def _set_clients(self):
        self._storage_client = StorageManagementClient(self.credential, self.subscription_id)

    def find_storage_account_by_prefix(self, resource_group_name, env_name) -> str:
        prefix = context.get_storage_account_name_prefix(env_name)
        try:
            accounts = self._storage_client.storage_accounts.list_by_resource_group(resource_group_name)
            for account in accounts:
                if account.name.startswith(prefix):
                    return account.name
            return ''
        except HttpResponseError as e:
            log.error(f"An error occurred while checking the storage accounts: {e}")
            raise
    
    def get_blob_service_client(self, account_name) -> BlobServiceClient:
        account_url = context.get_storage_account_url(account_name)
        log.info(f"Account URL: {account_url}")
        return BlobServiceClient(account_url=account_url, credential=self.credential)
    
    def upload_file_to_container(self, account_name, container_name, file_path) -> bool:
        try:
            blob_service_client = self.get_blob_service_client(account_name)
            blob_name = os.path.basename(file_path)
            container_client = blob_service_client.get_container_client(container_name)
            with open(file_path, "rb") as data:
                container_client.upload_blob(name=blob_name, data=data, overwrite=True)
            return True
        except Exception as e:
            log.error(f"An error occurred while uploading the file to the container: {e}")
            raise e
