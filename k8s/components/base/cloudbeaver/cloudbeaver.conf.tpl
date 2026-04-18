{
    "server": {
        "serverPort": 8978,
        "workspaceLocation": "workspace",
        "contentRoot": "web",
        "driversLocation": "drivers",
        "rootURI": "/",
        "serviceURI": "/api/",
        "productConfiguration": "conf/product.conf",
        "expireSessionAfterPeriod": 1800000,
        "develMode": false,
        "enableSecurityManager": true,
        "database": {
            "driver": "postgresql",
            "url": "jdbc:postgresql://postgres:5432/cloudbeaver",
            "user": "POSTGRES_USER",
            "password": "POSTGRES_PASSWORD",
            "createDatabase": true,
            "initialDataConfiguration": "conf/initial-data.conf",
            "pool": {
                "minIdleConnections": 4,
                "maxIdleConnections": 10,
                "maxConnections": 100,
                "validationQuery": "SELECT 1"
            }
        }
    },
    "app": {
        "anonymousAccessEnabled": false,
        "anonymousUserRole": "user",
        "supportsCustomConnections": true,
        "publicCredentialsSaveEnabled": false,
        "adminCredentialsSaveEnabled": false,
        "resourceManagerEnabled": true,
        "enabledAuthProviders": [
            "local"
        ],
        "disabledDrivers": [
            "h2:h2_embedded",
            "h2:h2_embedded_v2",
            "clickhouse:yandex_clickhouse",
            "generic:duckdb_jdbc",
            "sqlite:sqlite_jdbc"
        ]
    }
}
