# Alertmanager  Module
This is a terraform module used to install the ALERTMANAGER application into the Government PaaS, and setting some of the configuration.

### Inputs
```
   monitoring_space_id    MANDATORY
   monitoring_org_name    MANDATORY
   configuration          OPTIONAL
```

**monitoring_org_name** A unique name given to the application

**monitoring_space_id** The Cloud Foundry space you wish to deploy the application too.

**configuration**  The contents of an alertmanager.yml file, as specified in the [documentation](https://prometheus.io/docs/alerting/latest/configuration/) .
This can be provided in the calling code using.

```
module "alertmanager" {
   source              = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/alertmanager?ref=monitoring-terraform-0_13"
   monitoring_space_id = data.cloudfoundry_space.space.id
   monitoring_org_name = "test-alertmanager"
   config              = file( "../alertmanager.yml" )
}
```

