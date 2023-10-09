
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
  replicas: {{ .Values.matcher.replicas }}
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
