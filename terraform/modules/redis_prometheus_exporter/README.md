# REDIS Exporter Module
This is a terraform module used to install the [REDIS-EXPORTER](https://github.com/oliver006/redis_exporter)  application into the Government PaaS, and setting some of the configuration.


### Inputs
```monitoring_space_id           MANDATORY
   monitoring_instance_name      MANDATORY
   redis_service_instance_id     MANDATORY
```

### Outputs
``` endpoint    URL of Redis exporter endpoint, required by Prometheus
```

### Example Usage
```
module "redis" {
     source = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/redis_exporter?ref=master"

     monitoring_space_id                = data.cloudfoundry_space.space.id
     monitoring_instance_name           = "get_into_teaching"
     redis_service_instance_id          = data.cloudfoundry_service_instance.redis.id
}
```
