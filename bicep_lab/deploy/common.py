core_deploy_files = {
    'role': 'id.bicep',
    'vnet': 'vnet.bicep',
    'acr': 'acr.bicep',
    'keyvault': 'keyvault.bicep',
    'dev_vm': 'dev_vm.bicep'
}

apps_deploy_files = {
    'db': 'sqldb.bicep',
    'app_env': 'appcontainer.bicep',
    'frontend': 'frontendapp.bicep',
    'backend': 'backendapp.bicep',
    'scheduler': 'scheduleapp.bicep'
}

core_parallel_groups = [
    ['role'],
    ['vnet', 'acr', 'keyvault'],
    ['dev_vm']
]

apps_parallel_groups = [
    ['db', 'app_container'],
    ['app_env'],
    ['scheduler'],
    ['backend', 'scheduler'],
    ['frontend']
]
