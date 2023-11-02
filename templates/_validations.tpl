
{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "smartface.validate" -}}
{{- $messages := list -}}

{{- $messages := append $messages (trim (include "smartface.validate.multitenantEdge" .)) -}}
{{- $messages := append $messages (trim (include "smartface.validate.stationDeps" .)) -}}

{{- if not .Values.skipLookupBasedValidations -}}
{{- $messages := append $messages (trim (include "smartface.validate.dbConnectionSecret" .)) -}}
{{- $messages := append $messages (trim (include "smartface.validate.s3Config" .)) -}}
{{- $messages := append $messages (trim (include "smartface.validate.licenseSecret" .)) -}}
{{- $messages := append $messages (trim (include "smartface.validate.authConfig" .)) -}}
{{- $messages := append $messages (trim (include "smartface.validate.registryCreds" .)) -}}
{{- $messages := append $messages (trim (include "smartface.validate.rmqConfig" .)) -}}
{{- $messages := append $messages (trim (include "smartface.validate.mqttConfig" .)) -}}
{{- end -}}

{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}
{{- if $message -}}
{{-   printf "\nVALIDATIONS:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/*
Validate that users does not want multitenant edge streams
*/}}
{{- define "smartface.validate.multitenantEdge" -}}
{{- if and .Values.features.multitenancy.enabled .Values.features.edgeStreams.enabled -}}
Multitenancy is not supported for clusters with edge streams. Please disable one of the two features
{{- end -}}
{{- end -}}

{{/*
Validate that if station is requested then its dependencies are met
*/}}
{{- define "smartface.validate.stationDeps" -}}
{{- if .Values.station.enabled -}}
{{- if not .Values.authApi.enabled -}}
Station requires enabled authApi to work properly
{{- end -}}
{{- if not .Values.graphqlApi.enabled -}}
Station requires enabled graphqlApi to work properly
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validate that the Database connection string secret exists with correct key
*/}}
{{- define "smartface.validate.dbConnectionSecret" -}}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "Secret" "Namespace" .Release.Namespace "Name" .Values.configurations.database.existingSecretName "Key" .Values.configurations.database.connectionStringKey) }}
{{- end -}}

{{/*
Validate that the S3 config map exists with correct keys
*/}}
{{- define "smartface.validate.s3Config" -}}
{{- $existingConfigMap := .Values.configurations.s3.existingConfigMapName -}}
{{- if .Values.minio.enabled -}}
{{- if $existingConfigMap }}
Cannot deploy minio and use existing ConfigMap. Either disable minio deployment by setting `minio.enabled` to `false` or don't provide value for `configurations.s3.existingConfigMapName`
{{- end }}
{{- else}}
{{- if $existingConfigMap -}}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" $existingConfigMap "Key" "name") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" $existingConfigMap "Key" "region") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" $existingConfigMap "Key" "folder") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" $existingConfigMap "Key" "authType") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" $existingConfigMap "Key" "useBucketRegion") }}
{{- else }}
{{- if not .Values.configurations.s3.bucketName }}
Please provide value for `configurations.s3.bucketName`
{{- end }}
{{- if not .Values.configurations.s3.bucketRegion }}
Please provide value for `configurations.s3.bucketRegion`
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validate that the license secret exists with correct keys
*/}}
{{- define "smartface.validate.licenseSecret" -}}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "Secret" "Namespace" .Release.Namespace "Name" .Values.configurations.license.secretName "Key" "iengine.lic") }}
{{- end -}}

{{/*
Validate auth config present if it will be needed
*/}}
{{- define "smartface.validate.authConfig" -}}
{{- if or .Values.authApi.enabled .Values.graphqlApi.enableAuth -}}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.configurations.apiAuth.configName "Key" "use_auth") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.configurations.apiAuth.configName "Key" "authority") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.configurations.apiAuth.configName "Key" "audience") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.configurations.apiAuth.configName "Key" "oauth_token_url") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.configurations.apiAuth.configName "Key" "oauth_authorize_url") }}
{{- end -}}
{{- if .Values.station.enabled }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.configurations.stationAuth.configName "Key" "use_auth") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.configurations.stationAuth.configName "Key" "audience") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.configurations.stationAuth.configName "Key" "domain") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.configurations.stationAuth.configName "Key" "issuer") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.configurations.stationAuth.configName "Key" "jwks_uri") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.configurations.stationAuth.configName "Key" "auth_header") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "Secret" "Namespace" .Release.Namespace "Name" .Values.configurations.stationAuth.secretName "Key" "client_id") }}
{{- end -}}
{{- end -}}

{{/*
Validate registry credentials
*/}}
{{- define "smartface.validate.registryCreds" -}}
{{- $releaseName := .Release.Namespace -}}
{{- range .Values.imagePullSecrets -}}
{{- $error := (include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "Secret" "Namespace" $releaseName "Name" .name "Key" ".dockerconfigjson")) -}}
{{- if $error -}}
{{ printf "%s" ($error) }}
To create the secret follow the official documentation https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validate rmq config if not managed by us
*/}}
{{- define "smartface.validate.rmqConfig" -}}
{{- $existingConfigMap := .Values.rabbitmq.rmqConfiguration.existingConfigMapName -}}
{{- if .Values.rabbitmq.enabled -}}
{{- if $existingConfigMap }}
Cannot deploy rabbitmq and use existing ConfigMap. Either disable rabbitmq deployment by setting `rabbitmq.enabled` to `false` or don't provide value for `rabbitmq.rmqConfiguration.existingConfigMapName`
{{- end }}
{{- else }}
{{- if $existingConfigMap }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" $existingConfigMap "Key" "hostname") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" $existingConfigMap "Key" "useSsl") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" $existingConfigMap "Key" "port") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" $existingConfigMap "Key" "username") }}
{{- end }}
{{- if not .Values.rabbitmq.auth.existingSecretName }}
Please provide value for `rabbitmq.auth.existingSecretName`
{{- else }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "Secret" "Namespace" .Release.Namespace "Name" .Values.rabbitmq.existingSecretName "Key" .Values.rabbitmq.auth.secretKey) }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validate mqtt config if not managed by us
*/}}
{{- define "smartface.validate.mqttConfig" -}}
{{/*
This should not be used in such combination because there would be no "shovel" between mqtt and rmq, but we can still validate
*/}}
{{- if .Values.features.edgeStreams.enabled -}}
{{- $existingConfigMap := .Values.rabbitmq.mqttConfiguration.existingConfigMapName -}}
{{- if .Values.rabbitmq.enabled -}}
{{- if $existingConfigMap }}
Cannot deploy rabbitmq and use existing ConfigMap for MQTT. Either disable rabbitmq deployment by setting `rabbitmq.enabled` to `false` or don't provide value for `rabbitmq.mqttConfiguration.existingConfigMapName`
{{- end }}
{{- else }}
{{- if $existingConfigMap }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" $existingConfigMap "Key" "hostname") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" $existingConfigMap "Key" "useSsl") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" $existingConfigMap "Key" "port") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" $existingConfigMap "Key" "username") }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validate arbitrary k8s resource and presence of a field on it
*/}}
{{- define "smartface.validate.genericResourceWithKey" -}}
{{- $resource := (lookup .Version .Type .Namespace .Name).data -}}
{{- if $resource -}}
{{- $value := (index $resource .Key) -}}
{{- if not $value -}}
Resource of type "{{.Version}}/{{ .Type }}" with name "{{ .Name }}" in namespace "{{ .Namespace }}" is missing key "{{ .Key }}"
{{- end -}}
{{- else -}}
Resource of type "{{.Version}}/{{ .Type }}" with name "{{ .Name }}" in namespace "{{ .Namespace }}" not found
{{- end -}}
{{- end -}}
