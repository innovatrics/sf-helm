{{/*
Expand the name of the chart.
*/}}
{{- define "smartface.name" -}}
{{- coalesce .Values.nameOverride "sf" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "smartface.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "smartface.labels" -}}
helm.sh/chart: {{ include "smartface.chart" . }}
{{ include "smartface.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "smartface.selectorLabels" -}}
app.kubernetes.io/name: {{ include "smartface.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
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
Topology spread definition commonly used for most of our deployments
*/}}
{{- define "smartface.topologySpread" -}}
- maxSkew: 1
  topologyKey: "topology.kubernetes.io/zone"
  whenUnsatisfiable: ScheduleAnyway
  labelSelector:
    matchLabels:
      {{- .selectorLabels | nindent 6 }}
- maxSkew: 1
  topologyKey: "kubernetes.io/hostname"
  whenUnsatisfiable: ScheduleAnyway
  labelSelector:
    matchLabels:
      {{- .selectorLabels | nindent 6 }}
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
    "-c", "$(ConnectionStrings__CoreDbContext)",
    "-dbe", "$(Database__DbEngine)",
    "--rmq-host", "$(RabbitMQ__Hostname)",
    "--rmq-user", "$(RabbitMQ__Username)",
    "--rmq-pass", "$(RabbitMQ__Password)",
    "--rmq-port", "$(RabbitMQ__Port)",
    "--rmq-use-ssl", "$(RabbitMQ__UseSsl)",
    "--rmq-streams-port", "$(RabbitMQ__StreamsPort)",
    "--rmq-virtual-host", "/"]
  env:
    {{- include "smartface.dbConfig" . | nindent 4 }}
    {{- include "smartface.rmqConfig" . | nindent 4 }}
  resources:
    {{- toYaml .Values.migration.initContainer.resources | nindent 4 }}
  volumeMounts:
  {{- include "smartface.licVolumeMount" . | nindent 2 }}
{{- end -}}
