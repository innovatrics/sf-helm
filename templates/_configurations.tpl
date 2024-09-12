{{/*
Template used for adding database configuration to containers
*/}}
{{- define "smartface.dbConfig" -}}
{{- if .Values.postgresql.enabled }}
- name: "DB_HOST"
  value: "{{ .Release.Name }}-postgresql.{{ .Release.Namespace }}.svc.cluster.local"
- name: "DB_USER"
  value: "postgres"
- name: "DB_DATABASE"
  value: "smartface"
- name: "DB_PASSWORD"
  valueFrom:
    secretKeyRef:
      name: "{{ .Release.Name }}-postgresql"
      key: "postgres-password"
- name: "ConnectionStrings__CoreDbContext"
  value: "Server=$(DB_HOST);Database=$(DB_DATABASE);Username=$(DB_USER);Password='$(DB_PASSWORD)';"
{{- else }}
- name: "ConnectionStrings__CoreDbContext"
  valueFrom:
    secretKeyRef:
      name: {{ .Values.configurations.database.existingSecretName | quote }}
      key: {{ .Values.configurations.database.connectionStringKey | quote }}
{{- end }}
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
- name: "FeatureManagement__Detection"
  value: {{ .Values.features.objectDetection.enabled | quote }}
{{- end }}

{{/*
Template used for configuring Authentication on APIs
*/}}
{{- define "smartface.authenticationConfig" -}}
{{- $configName := ( .Values.configurations.apiAuth.existingConfigMapName | default (include "smartface.auth.name" . )) -}}
- name: "Authentication__UseAuthentication"
  value: "true"
- name: "Authentication__Authority"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName }}
      key: "authority"
- name: "Authentication__Audience"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName }}
      key: "audience"
- name: "Authentication__SwaggerAuthConfig__ClientCredsTokenUrl"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName }}
      key: "oauth_token_url"
      optional: true
- name: "Authentication__SwaggerAuthConfig__AuthCodeTokenUrl"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName }}
      key: "oauth_token_url"
      optional: true
- name: "Authentication__SwaggerAuthConfig__AuthCodeAuthorizeUrl"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName }}
      key: "oauth_authorize_url"
      optional: true
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

{{/*
Template used for setting up authentication data for test pods
*/}}
{{- define "smartface.testsAuthConfig" -}}
{{- $configName := ( .Values.configurations.apiAuth.existingConfigMapName | default (include "smartface.auth.name" . )) }}
- name: "SF_TENANT_1_NAME"
  value: {{ .Values.tests.authentication.tenant1.name }}
- name: "SF_TENANT_1_CLIENT_ID"
  value: {{ .Values.tests.authentication.tenant1.clientId }}
- name: "SF_TENANT_1_SECRET"
  value: {{ .Values.tests.authentication.tenant1.clientSecret }}
- name: "SF_TENANT_2_NAME"
  value: {{ .Values.tests.authentication.tenant2.name }}
- name: "SF_TENANT_2_CLIENT_ID"
  value: {{ .Values.tests.authentication.tenant2.clientId }}
- name: "SF_TENANT_2_SECRET"
  value: {{ .Values.tests.authentication.tenant2.clientSecret }}
- name: "SF_USE_AUTH"
  value: "true"
- name: "SF_AUTH_AUDIENCE"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName }}
      key: "audience"
- name: "SF_OAUTH_TOKEN_URL"
  valueFrom:
    configMapKeyRef:
      name: {{ $configName }}
      key: "oauth_token_url"
{{- end }}
