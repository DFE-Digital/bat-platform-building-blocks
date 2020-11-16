## Alertmanager  Module
This is a terraform module used to install the [alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) application into the Government PaaS, and setting some of the configuration.

It is deployed using the official docker image.

### Inputs
```
   monitoring_space_id         MANDATORY
   monitoring_instance_name    MANDATORY
   config                      OPTIONAL
   slack_url                   OPTIONAL
   slack_channel               OPTIONAL
```

- **monitoring_instance_name:** A unique name given to the application
- **monitoring_space_id:** The Cloud Foundry space you wish to deploy the application to
- **config:**  The contents of an alertmanager.yml file, as specified in the [documentation](https://prometheus.io/docs/alerting/latest/configuration/). If not specified, a dummy configuration is deployed.

### Example
```
module alertmanager {
   source                   = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/alertmanager"
   monitoring_space_id      = data.cloudfoundry_space.space.id
   monitoring_instance_name = "test-alertmanager"
   config                   = file("${path.module}/files/alertmanager.yml")
   slack_url                = https://hooks.slack.com/services/XXXXXXXXX/YYYYYYYYYYY/xxxxxxxxxxxxxxxxxxxxxxxx
   slack_channel            = mychannel
}
```

### Prometheus alerts

```
      - alert: TooManyRequests
        expr: 'sum(increase(tta_requests_total{path!~"csp_reports",status=~"429"}[1m])) > 0'
        labels:
          severity: high
        annotations:
          summary: Alert when any user hits a rate limit (excluding the /csp_reports endpoint).
          runbook: https://dfedigital.atlassian.net/wiki/spaces/GGIT/pages/2152497153/Rate+Limit
```

The severity should be one of high, medium or low

### Templates
A default set of slack templates have been provided

### Acknowledgements to
https://gist.github.com/milesbxf/e2744fc90e9c41b47aa47925f8ff6512

