
{{/*
Definition of matcher deployment manifest. Will either be used by tenant operator or directly
*/}}
{{- define "smartface.matcherDefinition" -}}
apiVersion: "apps/v1"
kind: "Deployment"
metadata:
  name: {{ .Values.matcher.name | quote }}
  labels:
    app: {{ .Values.matcher.name | quote }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .Values.matcher.name | quote }}
  template:
    metadata:
      labels:
        app: {{ .Values.matcher.name | quote }}
    spec:
      serviceAccountName: {{ .Values.serviceAccount.name | quote }}
      automountServiceAccountToken: {{ .Values.serviceAccount.automountServiceAccountToken }}
      topologySpreadConstraints:
        {{- include "smartface.topologySpread" (dict "appLabel" .Values.matcher.name) | nindent 8 }}
      imagePullSecrets:
      - name: {{ .Values.image.secretName | quote }}
      containers:
      - name: {{ .Values.matcher.name | quote }}
        image: "{{ .Values.image.registry }}sf-matcher:{{ .Chart.AppVersion }}"
        env:
        {{- include "smartface.commonEnv" . | nindent 8 }}
        {{- include "smartface.rmqConfig" . | nindent 8 }}
        {{- include "smartface.dbConfig" . | nindent 8 }}
        resources:
          {{- toYaml .Values.matcher.resources | nindent 10 }}
        volumeMounts:
        {{- include "smartface.licVolumeMount" . | nindent 8 }}
      volumes:
        {{- include "smartface.licVolume" . | nindent 8 }}
{{- end }}
