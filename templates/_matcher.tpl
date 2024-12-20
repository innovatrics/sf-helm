
{{/*
Definition of matcher deployment manifest. Will either be used by tenant operator or directly
*/}}
{{- define "smartface.matcherDefinition" -}}
{{- $name := include "smartface.matcher.name" . -}}
{{- $selectorLabels := include "smartface.matcher.selectorLabels" . -}}
apiVersion: "apps/v1"
kind: "Deployment"
metadata:
  name: {{ $name | quote }}
  labels:
    {{- include "smartface.matcher.labels" . | nindent 4 }}
  annotations:
    {{- with .Values.annotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- with .Values.matcher.annotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  replicas: {{ .Values.matcher.replicas }}
  {{- if .Values.revisionHistoryLimit }}
  revisionHistoryLimit: {{ .Values.revisionHistoryLimit }}
  {{- end }}
  {{- if .Values.updateStrategy }}
  strategy: {{- toYaml .Values.updateStrategy | nindent 4 }}
  {{- end }}
  selector:
    matchLabels:
      {{- $selectorLabels | nindent 6 }}
  template:
    metadata:
      annotations:
        {{- with .Values.podAnnotations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- with .Values.matcher.podAnnotations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      labels:
        {{- $selectorLabels | nindent 8 }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- with .Values.matcher.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      serviceAccountName: {{ .Values.serviceAccount.name | quote }}
      automountServiceAccountToken: {{ .Values.serviceAccount.automountServiceAccountToken }}
      topologySpreadConstraints:
        {{- include "smartface.topologySpread" (dict "selectorLabels" $selectorLabels ) | nindent 8 }}
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
      - name: {{ .Values.matcher.name | quote }}
        image: {{ include "smartface.image" (dict "local" .Values.matcher.image "global" .Values.global.image "defaultVersion" .Chart.AppVersion) }}
        imagePullPolicy: {{ .Values.matcher.image.pullPolicy }}
        env:
        {{- include "smartface.commonEnv" . | nindent 8 }}
        {{- include "smartface.rmqConfig" . | nindent 8 }}
        {{- include "smartface.dbConfig" . | nindent 8 }}
        {{- if .Values.configurations.faceTemplate.compatibilityVersion  }}
        - name: SF_FACE_TEMPLATE_COMPATIBILITY_VERSION
          value: {{ .Values.configurations.faceTemplate.compatibilityVersion | quote }}
        {{- end }}
        {{- with .Values.matcher.extraVars }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        resources:
          {{- toYaml .Values.matcher.resources | nindent 10 }}
        volumeMounts:
        {{- include "smartface.licVolumeMount" . | nindent 8 }}
      volumes:
        {{- include "smartface.licVolume" . | nindent 8 }}
      {{- with .Values.matcher.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.matcher.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
