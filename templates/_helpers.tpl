{{/*
Template used for adding database configuration to containers
*/}}
{{- define "smartface.dbConfig" -}}
- name: "ConnectionStrings__CoreDbContext"
  valueFrom:
    secretKeyRef:
      name: {{ .Values.configurations.database.secretName | quote }}
      key: {{ .Values.configurations.database.connectionStringKey | quote }}
- name: "Database__DbEngine"
  value: "PgSql"
{{- end }}

{{/*
Template used for resolving SF images using global/local overrides
*/}}
{{- define "smartface.image" }}
{{- $registry := .global.registry | default .local.registry | default "" -}}
{{- $repository := .local.repository | default "" -}}
{{- $ref := ternary (printf ":%s" (.local.tag | default .defaultVersion | toString)) (printf "@%s" .local.digest) (empty .local.digest) -}}
{{- if and $registry $repository -}}
  {{- printf "%s/%s%s" $registry $repository $ref -}}
{{- else -}}
  {{- printf "%s%s%s" $registry $repository $ref -}}
{{- end -}}
{{- end -}}

{{/*
Template used for adding S3 configuration to containers
*/}}
{{- define "smartface.s3Config" -}}
- name: "S3Bucket__BucketName"
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.configurations.s3.configName | quote }}
      key: {{ .Values.configurations.s3.bucketKey | quote }}
- name: "S3Bucket__BucketRegion"
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.configurations.s3.configName | quote }}
      key: {{ .Values.configurations.s3.regionKey | quote }}
- name: "S3Bucket__Folder"
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.configurations.s3.configName | quote }}
      key: {{ .Values.configurations.s3.folderKey | quote }}
# AssumedRole
- name: "S3Bucket__AuthenticationType"
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.configurations.s3.configName | quote }}
      key: {{ .Values.configurations.s3.authTypeKey | quote }}
# BucketRegion
- name: "S3Bucket__useBucketEndpoint"
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.configurations.s3.configName | quote }}
      key: {{ .Values.configurations.s3.useBucketEndpointKey | quote }}
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
- name: "RabbitMQ__Hostname"
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.rabbitmq.configMapName | quote }}
      key: "hostname"
- name: "RabbitMQ__UseSsl"
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.rabbitmq.configMapName | quote }}
      key: "useSsl"
- name: "RabbitMQ__Port"
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.rabbitmq.configMapName | quote }}
      key: "port"
- name: "RabbitMQ__Username"
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.rabbitmq.configMapName | quote }}
      key: "username"
- name: "RabbitMQ__Password"
  valueFrom:
    secretKeyRef:
      {{- if .Values.rabbitmq.existingSecretName }}
      name: {{ .Values.rabbitmq.existingSecretName | quote }}
      {{- else }}
      name: "{{ .Release.Name }}-rabbitmq"
      {{- end }}
      key: {{ .Values.rabbitmq.secretKey | quote }}
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
Topology spread definition commonly used for most of our deployments
*/}}
{{- define "smartface.topologySpread" -}}
- maxSkew: 1
  topologyKey: "topology.kubernetes.io/zone"
  whenUnsatisfiable: ScheduleAnyway
  labelSelector:
    matchLabels:
      app: {{ .appLabel | quote }}
- maxSkew: 1
  topologyKey: "kubernetes.io/hostname"
  whenUnsatisfiable: ScheduleAnyway
  labelSelector:
    matchLabels:
      app: {{ .appLabel | quote }}
{{- end -}}

{{/*
Init container to perform database migration before starting the main container
*/}}
{{- define "smartface.migrationInitContainer" -}}
- name: "sf-migration"
  image: {{ include "smartface.image" (dict "local" .Values.migration.initContainer.image "global" .Values.global.image "defaultVersion" .Chart.AppVersion) }}
  args: [
    "run-migration",
    "-p", "1",
    "-c", "$(db_cs)",
    "-dbe", "PgSql",
    "--rmq-host", "$(RabbitMQ__Hostname)",
    "--rmq-user", "$(RabbitMQ__Username)",
    "--rmq-pass", "$(RabbitMQ__Password)",
    "--rmq-port", "$(RabbitMQ__Port)",
    "--rmq-use-ssl", "$(RabbitMQ__UseSsl)",
    "--rmq-virtual-host", "/"]
  env:
    - name: "db_cs"
      valueFrom:
        secretKeyRef:
          name: {{ .Values.configurations.database.secretName | quote }}
          key: {{ .Values.configurations.database.connectionStringKey | quote }}
    {{- include "smartface.rmqConfig" . | nindent 4 }}
  resources:
    {{- toYaml .Values.migration.initContainer.resources | nindent 4 }}
  volumeMounts:
  {{- include "smartface.licVolumeMount" . | nindent 2 }}
{{- end -}}
