# REDIS Exporter Module
This is a terraform module used to install the REDIS-EXPORTER application into the Government PaaS, and setting some of the configuration.

### Inputs
```space_id               MANDATORY
   name                   MANDATORY
   redis-service-name     MANDATORY

```

### Outputs
``` endpoint    URL of Redis exporters endpoint, required by Prometheus
```

### Example Usage
```
module "redis" {
     source = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/redis_exporter?ref=master"

     space_id                = data.cloudfoundry_space.space.id
     name                    = "redis"
     redis-service-name      = "redis-service-name"
}
```

