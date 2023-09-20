
{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "sf-cloud-matcher.validate" -}}
{{- $messages := list -}}
{{- $messages := append $messages (trim (include "sf-cloud-matcher.validate.multitenantEdge" .)) -}}
{{- $messages := append $messages (trim (include "sf-cloud-matcher.validate.dbConnectionSecret" .)) -}}
{{- $messages := append $messages (trim (include "sf-cloud-matcher.validate.s3Config" .)) -}}
{{- $messages := append $messages (trim (include "sf-cloud-matcher.validate.licenseSecret" .)) -}}
{{- $messages := append $messages (trim (include "sf-cloud-matcher.validate.authConfig" .)) -}}
{{- $messages := append $messages (trim (include "sf-cloud-matcher.validate.registryCreds" .)) -}}
{{- $messages := append $messages (trim (include "sf-cloud-matcher.validate.rmqConfig" .)) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALIDATIONS:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/*
Validate that users does not want multitenant edge streams
*/}}
{{- define "sf-cloud-matcher.validate.multitenantEdge" -}}
{{- if and .Values.multitenancy.enabled .Values.edgeStreams.enabled -}}
Multitenancy is not supported for clusters with edge streams. Please disable one of the two features
{{- end -}}
{{- end -}}

{{/*
Validate that the Database connection string secret exists with correct key
*/}}
{{- define "sf-cloud-matcher.validate.dbConnectionSecret" -}}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "Secret" "Namespace" .Release.Namespace "Name" .Values.database.secretName "Key" .Values.database.connectionStringKey) }}
{{- end -}}

{{/*
Validate that the S3 config map exists with correct keys
*/}}
{{- define "sf-cloud-matcher.validate.s3Config" -}}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.s3.configName "Key" .Values.s3.bucketKey) }}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.s3.configName "Key" .Values.s3.regionKey) }}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.s3.configName "Key" .Values.s3.folderKey) }}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.s3.configName "Key" .Values.s3.authTypeKey) }}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.s3.configName "Key" .Values.s3.endpointTypeKey) }}
{{- end -}}

{{/*
Validate that the license secret exists with correct keys
*/}}
{{- define "sf-cloud-matcher.validate.licenseSecret" -}}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "Secret" "Namespace" .Release.Namespace "Name" .Values.license.secretName "Key" "iengine.lic") }}
{{- end -}}

{{/*
Validate auth config present if it will be needed
*/}}
{{- define "sf-cloud-matcher.validate.authConfig" -}}
{{- if or .Values.authApi.enabled .Values.graphqlApi.enableAuth -}}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.auth.configName "Key" "use_auth") }}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.auth.configName "Key" "authority") }}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.auth.configName "Key" "audience") }}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.auth.configName "Key" "oauth_token_url") }}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.auth.configName "Key" "oauth_authorize_url") }}
{{- end -}}
{{- if .Values.station.enabled }}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.stationAuth.configName "Key" "use_auth") }}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.stationAuth.configName "Key" "audience") }}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.stationAuth.configName "Key" "domain") }}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.stationAuth.configName "Key" "issuer") }}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.stationAuth.configName "Key" "jwks_uri") }}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.stationAuth.configName "Key" "auth_header") }}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "Secret" "Namespace" .Release.Namespace "Name" .Values.stationAuth.secretName "Key" "client_id") }}
{{- end -}}
{{- end -}}

{{/*
Validate registry credentials
*/}}
{{- define "sf-cloud-matcher.validate.registryCreds" -}}
{{- $error := (include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "Secret" "Namespace" .Release.Namespace "Name" .Values.image.secretName "Key" ".dockerconfigjson")) -}}
{{- if $error -}}
{{ printf "%s" ($error) }}
To create the secret follow the official documentation https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
{{- end -}}
{{- end -}}

{{/*
Validate rmq config if not managed by us
*/}}
{{- define "sf-cloud-matcher.validate.rmqConfig" -}}
{{- if not .Values.rabbitmq.enabled -}}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.rabbitmq.configMapName "Key" "hostname") }}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.rabbitmq.configMapName "Key" "useSsl") }}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.rabbitmq.configMapName "Key" "port") }}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "ConfigMap" "Namespace" .Release.Namespace "Name" .Values.rabbitmq.configMapName "Key" "username") }}
{{- if not .Values.rabbitmq.existingSecretName }}
Please provide value for `rabbitmq.existingSecretName`
{{- else }}
{{ include "sf-cloud-matcher.validate.genericResourceWithKey" (dict "Version" "v1" "Type" "Secret" "Namespace" .Release.Namespace "Name" .Values.rabbitmq.existingSecretName "Key" .Values.rabbitmq.secretKey) }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validate arbitrary k8s resource and presence of a field on it
*/}}
{{- define "sf-cloud-matcher.validate.genericResourceWithKey" -}}
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
