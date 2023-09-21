
{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "smartface.validate" -}}
{{- $messages := list -}}
{{- $messages := append $messages (trim (include "smartface.validate.multitenantEdge" .)) -}}
{{- $messages := append $messages (trim (include "smartface.validate.dbConnectionSecret" .)) -}}
{{- $messages := append $messages (trim (include "smartface.validate.s3Config" .)) -}}
{{- $messages := append $messages (trim (include "smartface.validate.licenseSecret" .)) -}}
{{- $messages := append $messages (trim (include "smartface.validate.authConfig" .)) -}}
{{- $messages := append $messages (trim (include "smartface.validate.registryCreds" .)) -}}
{{- $messages := append $messages (trim (include "smartface.validate.rmqConfig" .)) -}}
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
{{- if and .Values.multitenancy.enabled .Values.edgeStreams.enabled -}}
Multitenancy is not supported for clusters with edge streams. Please disable one of the two features
{{- end -}}
{{- end -}}

{{/*
Validate that the Database connection string secret exists with correct key
*/}}
{{- define "smartface.validate.dbConnectionSecret" -}}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "Secret" "Namespace" .Release.Namespace "Name" .Values.database.secretName "Key" .Values.database.connectionStringKey) }}
{{- end -}}

{{/*
Validate that the S3 config map exists with correct keys
*/}}
{{- define "smartface.validate.s3Config" -}}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.s3.configName "Key" .Values.s3.bucketKey) }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.s3.configName "Key" .Values.s3.regionKey) }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.s3.configName "Key" .Values.s3.folderKey) }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.s3.configName "Key" .Values.s3.authTypeKey) }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.s3.configName "Key" .Values.s3.endpointTypeKey) }}
{{- end -}}

{{/*
Validate that the license secret exists with correct keys
*/}}
{{- define "smartface.validate.licenseSecret" -}}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "Secret" "Namespace" .Release.Namespace "Name" .Values.license.secretName "Key" "iengine.lic") }}
{{- end -}}

{{/*
Validate auth config present if it will be needed
*/}}
{{- define "smartface.validate.authConfig" -}}
{{- if or .Values.authApi.enabled .Values.graphqlApi.enableAuth -}}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.auth.configName "Key" "use_auth") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.auth.configName "Key" "authority") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.auth.configName "Key" "audience") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.auth.configName "Key" "oauth_token_url") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.auth.configName "Key" "oauth_authorize_url") }}
{{- end -}}
{{- if .Values.station.enabled }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.stationAuth.configName "Key" "use_auth") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.stationAuth.configName "Key" "audience") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.stationAuth.configName "Key" "domain") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.stationAuth.configName "Key" "issuer") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.stationAuth.configName "Key" "jwks_uri") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.stationAuth.configName "Key" "auth_header") }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "Secret" "Namespace" .Release.Namespace "Name" .Values.stationAuth.secretName "Key" "client_id") }}
{{- end -}}
{{- end -}}

{{/*
Validate registry credentials
*/}}
{{- define "smartface.validate.registryCreds" -}}
{{- $error := (include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "Secret" "Namespace" .Release.Namespace "Name" .Values.image.secretName "Key" ".dockerconfigjson")) -}}
{{- if $error -}}
{{ printf "%s" ($error) }}
To create the secret follow the official documentation https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
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
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.rabbitmq.configMapName "Key" "username") }}
{{- if not .Values.rabbitmq.existingSecretName }}
Please provide value for `rabbitmq.existingSecretName`
{{- else }}
{{ include "smartface.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "Secret" "Namespace" .Release.Namespace "Name" .Values.rabbitmq.existingSecretName "Key" .Values.rabbitmq.secretKey) }}
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
