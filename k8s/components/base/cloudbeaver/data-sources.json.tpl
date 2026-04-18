{
    "connections": {
        "postgres-local": {
            "provider": "postgresql",
            "driver": "postgres-jdbc",
            "name": "PostgreSQL (Local)",
            "save-password": true,
            "configuration": {
                "host": "postgres",
                "port": "5432",
                "database": "postgres",
                "user": "POSTGRES_USER",
                "password": "POSTGRES_PASSWORD",
                "url": "jdbc:postgresql://postgres:5432/postgres",
                "type": "dev"
            }
        }
    }
}
