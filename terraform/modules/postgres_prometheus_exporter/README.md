# POSTGRES Exporter Module
This is a terraform module used to install the POSTGRES-EXPORTER application into the Government PaaS, and setting some of the configuration.

### Inputs
```space_id               MANDATORY
   name                   MANDATORY
   postgres-service-name     MANDATORY

```

### Outputs
``` endpoint    URL of Redis exporters endpoint, required by Prometheus
```

### Example Usage
```
module "postgres" {
     source = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/postgres_exporter?ref=master"

     space_id                = data.cloudfoundry_space.space.id
     name                    = "postgres"
     postgres-service-name   = "postgres-service-name"
}
```

