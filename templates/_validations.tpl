
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
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "Secret" "Namespace" .Release.Namespace "Name" .Values.configurations.database.secretName "Key" .Values.configurations.database.connectionStringKey) }}
{{- end -}}

{{/*
Validate that the S3 config map exists with correct keys
*/}}
{{- define "smartface.validate.s3Config" -}}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.configurations.s3.configName "Key" .Values.configurations.s3.bucketKey) }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.configurations.s3.configName "Key" .Values.configurations.s3.regionKey) }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.configurations.s3.configName "Key" .Values.configurations.s3.folderKey) }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.configurations.s3.configName "Key" .Values.configurations.s3.authTypeKey) }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.configurations.s3.configName "Key" .Values.configurations.s3.useBucketRegionKey) }}
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
{{- if not .Values.rabbitmq.enabled -}}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.rabbitmq.configMapName "Key" "hostname") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.rabbitmq.configMapName "Key" "useSsl") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.rabbitmq.configMapName "Key" "port") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.rabbitmq.configMapName "Key" "streamsPort") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.rabbitmq.configMapName "Key" "username") }}
{{- if not .Values.rabbitmq.existingSecretName }}
Please provide value for `rabbitmq.existingSecretName`
{{- else }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "Secret" "Namespace" .Release.Namespace "Name" .Values.rabbitmq.existingSecretName "Key" .Values.rabbitmq.secretKey) }}
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
{{- if and .Values.features.edgeStreams.enabled (not .Values.rabbitmq.enabled) -}}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.rabbitmq.mqttConfigMapName "Key" "hostname") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.rabbitmq.mqttConfigMapName "Key" "useSsl") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.rabbitmq.mqttConfigMapName "Key" "port") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.rabbitmq.mqttConfigMapName "Key" "username") }}
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
