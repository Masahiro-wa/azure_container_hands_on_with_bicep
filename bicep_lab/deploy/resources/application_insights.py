from azure.mgmt.applicationinsights import ApplicationInsightsManagementClient
from deploy.utils import log
from .base import Base

class ApplicationInsights(Base):
    def __init__(self, subscription_id):
        super().__init__(subscription_id)
        self._set_clients()
    
    def _set_clients(self):
        self._app_insights_client = ApplicationInsightsManagementClient(self.credential, self.subscription_id)

    def get_connection_string(self, rg_name, app_insights_name):
        """
        Azure Application Insights の接続文字列を取得する関数

        Args:
            subscription_id (str): Azure サブスクリプション ID
            resource_group_name (str): リソースグループ名
            app_insights_name (str): Application Insights 名

        Returns:
            str: 接続文字列 (Connection String)
        """
        try:
            resource = self._app_insights_client.components.get(rg_name, app_insights_name)
            connection_string = resource.connection_string
            return connection_string
        
        except Exception as e:
            log.error(f"An error occurred: {e}")
            raise
