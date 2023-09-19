
{{/*
Definition of matcher deployment manifest. Will either be used by tenant operator or directly
*/}}
{{- define "sf-cloud-matcher.matcherDefinition" -}}
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
      topologySpreadConstraints:
        {{- include "sf-cloud-matcher.topologySpread" (dict "appLabel" .Values.matcher.name) | nindent 8 }}
      imagePullSecrets:
      - name: {{ .Values.image.secretName | quote }}
      containers:
      - name: {{ .Values.matcher.name | quote }}
        image: "{{ .Values.image.registry }}sf-matcher:{{ .Chart.AppVersion }}"
        env:
        {{- include "sf-cloud-matcher.commonEnv" . | nindent 8 }}
        {{- include "sf-cloud-matcher.rmqConfig" . | nindent 8 }}
        {{- include "sf-cloud-matcher.dbConfig" . | nindent 8 }}
        resources:
          requests:
            memory: "200M"
            cpu: {{ .Values.matcher.cpuRequests | quote }}
        volumeMounts:
        {{- include "sf-cloud-matcher.licVolumeMount" . | nindent 8 }}
      volumes:
        {{- include "sf-cloud-matcher.licVolume" . | nindent 8 }}
{{- end }}
