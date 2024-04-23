{{- define "smartface.wlStreamPopulationJob" -}}
apiVersion: "batch/v1"
kind: "Job"
metadata:
  name: "wlstream-population"
spec:
  template:
    spec:
      serviceAccountName: {{ .Values.serviceAccount.name | quote }}
      automountServiceAccountToken: {{ .Values.serviceAccount.automountServiceAccountToken }}
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
      - name: "sf-wl-update-log-population"
        image: {{ include "smartface.image" (dict "local" .Values.wlStreamPopulationJob.image "global" .Values.global.image "defaultVersion" .Chart.AppVersion) }}
        # this is not multitenant, so we pass "default"
        # maybe we should generate UUID for generation ID
        args: [
          "populate-wl-update-log-stream",

          "--rmq-host", "$(RabbitMQ__Hostname)",
          "--rmq-user", "$(RabbitMQ__Username)",
          "--rmq-pass", "$(RabbitMQ__Password)",
          "--rmq-port", "$(RabbitMQ__Port)",
          "--rmq-use-ssl", "$(RabbitMQ__UseSsl)",
          "--rmq-virtual-host", "/",
          "--rmq-streams-port", "$(RabbitMQ__StreamsPort)",

          "--connection-string", "$(ConnectionStrings__CoreDbContext)",
          "-dbe", "$(Database__DbEngine)",

          "--generation-id", "$(GENERATION_ID)",
          "--tenant-id", "$(Multitenancy__TenantId)"
        ]
        env:
        {{- include "smartface.dbConfig" . | nindent 8 }}
        {{- include "smartface.rmqConfig" . | nindent 8 }}
        volumeMounts:
        {{- include "smartface.licVolumeMount" . | nindent 8 }}
        resources:
          {{- toYaml .Values.wlStreamPopulationJob.resources | nindent 10 }}
      volumes:
        {{- include "smartface.licVolume" . | nindent 8 }}
      {{- with .Values.wlStreamPopulationJob.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.wlStreamPopulationJob.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      restartPolicy: "Never"
  backoffLimit: 4
{{- end }}
