```ruby
if [type] == "syslog" {
    # cf logs
    grok {
      # attempt to parse syslog lines
      match => { "message" => "(%{NONNEGINT:message_length} )?%{SYSLOG5424PRI}%{NONNEGINT:syslog_ver} (?:%{TIMESTAMP_ISO8601:syslog_timestamp}|-) +%{DATA:syslog_host} +%{UUID:cf_app_guid} +\[%{DATA:syslog_proc}\] +- +(\[tags@%{NONNEGINT} +%{DATA:cf_tags}\])? +%{GREEDYDATA:syslog_msg}" }
      # if successful, save original `@timestamp` and `host` fields created by logstash
      add_field => [ "received_at", "%{@timestamp}" ]
      add_field => [ "received_from", "%{host}" ]
      tag_on_failure => ["_syslogparsefailure"]
      remove_field => [ "message" ]
    }

    if [cf_tags] {
      kv {
        source => "cf_tags"
        target => "cf_tags"
        value_split => "="
      }
    }

    # parse the syslog pri field into severity/facility
    syslog_pri { syslog_pri_field_name => 'syslog5424_pri' }

    # replace @timestamp field with the one from syslog
    date { match => [ "syslog_timestamp", "ISO8601" ] }

    # Cloud Foundry passes the app name, space and organisation in the syslog_host
    # Filtering them into separate fields makes it easier to query multiple apps in a single Kibana instance
    dissect {
        mapping => { "syslog_host" => "%{[cf][org]}.%{[cf][space]}.%{[cf][app]}" }
        tag_on_failure => ["_sysloghostdissectfailure"]
    }

    # Cloud Foundry gorouter logs
    if [syslog_proc] =~ "RTR" {
        mutate { replace => { "type" => "gorouter" } }
        grok {
            match => { "syslog_msg" => "%{HOSTNAME:[access][host]} - \[%{TIMESTAMP_ISO8601:router_timestamp}\] \"%{WORD:[access][method]} %{NOTSPACE:[access][url]} HTTP/%{NUMBER:[access][http_version]}\" %{NONNEGINT:[access][response_code]:int} %{NONNEGINT:[access][body_received][bytes]:int} %{NONNEGINT:[access][body_sent][bytes]:int} %{QUOTEDSTRING:[access][referrer]} %{QUOTEDSTRING:[access][agent]} \"%{HOSTPORT:[access][remote_ip_and_port]}\" \"%{HOSTPORT:[access][upstream_ip_and_port]}\" %{GREEDYDATA:router_keys}" }
            tag_on_failure => ["_routerparsefailure"]
            add_tag => ["gorouter"]
        }
        # replace @timestamp field with the one from router access log
        date {
            match => [ "router_timestamp", "ISO8601" ]
        }
        kv {
            source => "router_keys"
            target => "router"
            value_split => ":"
            remove_field => "router_keys"
        }

        mutate {
          convert => {
            "[router][response_time]" => "float"
            "[router][gorouter_time]" => "float"
            "[router][app_index]" => "integer"
          }
        }
    }

    # Application logs
    if [syslog_proc] =~ "APP" {
        json {
            source => "syslog_msg"
            add_tag => ["app"]
        }
    }

    # User agent parsing
    if [access][agent] {
        useragent {
            source => "[access][agent]"
            target => "[access][user_agent]"
        }
    }

    if !("_syslogparsefailure" in [tags]) {
        # if we successfully parsed syslog, replace the message and source_host fields
        mutate {
            rename => [ "syslog_host", "source_host" ]
            copy => { "[cf][app]" => "application" }
            remove_field => ["syslog_msg" ]
        }
    }
  }
  ```
