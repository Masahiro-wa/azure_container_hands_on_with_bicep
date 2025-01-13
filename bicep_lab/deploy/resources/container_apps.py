from azure.mgmt.appcontainers import ContainerAppsAPIClient
from .base import Base

class ContainerApps(Base):
    def __init__(self, subscription_id):
        super().__init__(subscription_id)
        self._set_clients()
    
    def _set_clients(self):
        self._container_app_client = ContainerAppsAPIClient(self.credential, self.subscription_id)

    def get_container_app_fqdn(self, rg_name, container_app_name) -> str:
        """
        Azure Container Apps の名前から FQDN を取得する関数

        Args:
            subscription_id (str): Azure サブスクリプション ID
            resource_group_name (str): リソースグループ名
            container_app_name (str): Container Apps の名前

        Returns:
            str: FQDN (Fully Qualified Domain Name)
        """
        try:
            # Container Apps の詳細を取得
            container_app = self._container_app_client.container_apps.get(rg_name, container_app_name)
            # FQDN を取得
            print(container_app)
            fqdn = container_app.properties.configuration.ingress.fqdn
            return fqdn
        except Exception as e:
            print(f"An error occurred: {e}")
            return None

