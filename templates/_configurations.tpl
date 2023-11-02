{{/*
Template used for adding database configuration to containers
*/}}
{{- define "smartface.dbConfig" -}}
- name: "ConnectionStrings__CoreDbContext"
  valueFrom:
    secretKeyRef:
      name: {{ .Values.configurations.database.existingSecretName | quote }}
      key: {{ .Values.configurations.database.connectionStringKey | quote }}
- name: "Database__DbEngine"
  value: "PgSql"
{{- end }}

{{/*
Template used for adding S3 configuration to containers
*/}}
{{- define "smartface.s3Config" -}}
{{- $configName := ( .Values.configurations.s3.existingConfigMapName | default (include "smartface.s3.name" . )) -}}
- name: "S3Bucket__BucketName"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName | quote }}
      key: "name"
- name: "S3Bucket__BucketRegion"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName | quote }}
      key: "region"
      optional: true
- name: "S3Bucket__Folder"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName | quote }}
      key: "folder"
      optional: true
- name: "S3Bucket__AuthenticationType"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName | quote }}
      key: "authType"
- name: "S3Bucket__UseBucketRegion"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName | quote }}
      key: "useBucketRegion"
{{- if .Values.minio.enabled }}
- name: "S3Bucket__Endpoint"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName | quote }}
      key: "endpoint"
      optional: true
- name: "S3Bucket__AccessKey"
  valueFrom:
    secretKeyRef:
      name: "{{ .Release.Name }}-minio"
      key: "root-user"
- name: "S3Bucket__SecretKey"
  valueFrom:
    secretKeyRef:
      name: "{{ .Release.Name }}-minio"
      key: "root-password"
{{- end }}
{{- end }}

{{/*
Template used for configuring feature flags on APIs
*/}}
{{- define "smartface.apiFeaturesConfig" -}}
- name: "FeatureManagement__Full"
  value: "false"
- name: "FeatureManagement__Watchlist"
  value: "true"
- name: "FeatureManagement__Edge"
  value: {{ .Values.features.edgeStreams.enabled | quote }}
{{- end }}

{{/*
Template used for configuring Authentication on APIs
*/}}
{{- define "smartface.authenticationConfig" -}}
- name: "Authentication__UseAuthentication"
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.configurations.apiAuth.configName | quote }}
      key: "use_auth"
- name: "Authentication__Authority"
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.configurations.apiAuth.configName | quote }}
      key: "authority"
- name: "Authentication__Audience"
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.configurations.apiAuth.configName | quote }}
      key: "audience"
- name: "Authentication__SwaggerAuthConfig__ClientCredsTokenUrl"
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.configurations.apiAuth.configName | quote }}
      key: "oauth_token_url"
- name: "Authentication__SwaggerAuthConfig__AuthCodeTokenUrl"
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.configurations.apiAuth.configName | quote }}
      key: "oauth_token_url"
- name: "Authentication__SwaggerAuthConfig__AuthCodeAuthorizeUrl"
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.configurations.apiAuth.configName | quote }}
      key: "oauth_authorize_url"
{{- end }}

{{/*
Template used for adding RMQ configuration to containers
*/}}
{{- define "smartface.rmqConfig" -}}
{{- $configName := (.Values.rabbitmq.rmqConfiguration.existingConfigMapName | default (include "smartface.rabbitmq.name" . )) -}}
- name: "RabbitMQ__Hostname"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName | quote }}
      key: "hostname"
- name: "RabbitMQ__UseSsl"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName | quote }}
      key: "useSsl"
- name: "RabbitMQ__Port"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName | quote }}
      key: "port"
- name: "RabbitMQ__StreamsPort"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName | quote }}
      key: "streamsPort"
      optional: true
- name: "RabbitMQ__Username"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName | quote }}
      key: "username"
- name: "RabbitMQ__Password"
  valueFrom:
    secretKeyRef:
      {{- if .Values.rabbitmq.auth.existingSecretName }}
      name: {{ .Values.rabbitmq.auth.existingSecretName | quote }}
      {{- else }}
      name: "{{ .Release.Name }}-rabbitmq"
      {{- end }}
      key: {{ .Values.rabbitmq.auth.secretKey | quote }}
{{- end }}

{{/*
Template used for adding MQTT configuration to containers
*/}}
{{- define "smartface.mqttConfig" -}}
{{- $configName := (.Values.rabbitmq.rmqConfiguration.existingConfigMapName | default (include "smartface.rabbitmq.mqttName" . )) -}}
- name: "MQTT__Hostname"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName | quote }}
      key: "hostname"
- name: "MQTT__UseSsl"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName | quote }}
      key: "useSsl"
- name: "MQTT__Port"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName | quote }}
      key: "port"
- name: "MQTT__Username"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName | quote }}
      key: "username"
- name: "MQTT__Password"
  valueFrom:
    secretKeyRef:
      {{- if .Values.rabbitmq.auth.existingSecretName }}
      name: {{ .Values.rabbitmq.auth.existingSecretName | quote }}
      {{- else }}
      name: "{{ .Release.Name }}-rabbitmq"
      {{- end }}
      key: {{ .Values.rabbitmq.auth.secretKey | quote }}
{{- end }}

{{/*
Template used for adding license volume to deployment definition
*/}}
{{- define "smartface.licVolume" -}}
- name: {{ .Values.configurations.license.volumeMountName | quote }}
  secret:
    secretName: {{ .Values.configurations.license.secretName | quote }}
{{- end }}

{{/*
Template used for binding the license volume to containers
*/}}
{{- define "smartface.licVolumeMount" -}}
- name: {{ .Values.configurations.license.volumeMountName | quote }}
  mountPath: {{ .Values.configurations.license.mountPath | quote }}
  readOnly: true
{{- end }}

{{/*
Template used for common environment variables definition
*/}}
{{- define "smartface.commonEnv" -}}
- name: "AppSettings__Log-RollingFile-Enabled"
  value: "false"
- name: "AppSettings__Log_RollingFile_Enabled"
  value: "false"
- name: "AppSettings__Log_JsonConsole_Enabled"
  value: "true"
- name: "AppSettings__USE_JAEGER_APP_SETTINGS"
  value: {{ .Values.jaegerTracing.enabled | quote }}
- name: "JAEGER_AGENT_HOST"
  value: {{ .Values.jaegerTracing.hostname | quote }}
- name: "Metrics__PROMETHEUS_METRIC_SERVER_HOSTNAME"
  value: "*"
- name: "S3ClientLifetime__S3ClientLifetime"
  value: "Singleton"
{{- end }}

{{/*
Enabling statistics pulishing for countly sender
*/}}
{{- define "smartface.statisticsPublish" -}}
- name: "Statistics__SendStatisticsData"
  value: {{ .Values.countlyPublisher.enabled | quote }}
{{- end }}
