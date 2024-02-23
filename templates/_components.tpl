{{/*
api
*/}}
{{/*
Template used for resolving SF api name
*/}}
{{- define "smartface.api.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := .Values.api.name -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Template used for resolving labels for api component
*/}}
{{- define "smartface.api.labels" }}
{{- include "smartface.labels" . }}
app.kubernetes.io/component: "api"
{{- end -}}

{{/*
Template used for resolving selector labels for api component
*/}}
{{- define "smartface.api.selectorLabels" }}
{{- include "smartface.selectorLabels" . }}
app.kubernetes.io/component: "api"
{{- end -}}

{{/*
authApi
*/}}
{{/*
Template used for resolving SF authApi name
*/}}
{{- define "smartface.authApi.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := .Values.authApi.name -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Template used for resolving labels for authApi component
*/}}
{{- define "smartface.authApi.labels" }}
{{- include "smartface.labels" . }}
app.kubernetes.io/component: "authApi"
{{- end -}}

{{/*
Template used for resolving selector labels for authApi component
*/}}
{{- define "smartface.authApi.selectorLabels" }}
{{- include "smartface.selectorLabels" . }}
app.kubernetes.io/component: "authApi"
{{- end -}}

{{/*
graphqlApi
*/}}
{{/*
Template used for resolving SF graphqlApi name
*/}}
{{- define "smartface.graphqlApi.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := .Values.graphqlApi.name -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Template used for resolving labels for graphqlApi component
*/}}
{{- define "smartface.graphqlApi.labels" }}
{{- include "smartface.labels" . }}
app.kubernetes.io/component: "graphqlApi"
{{- end -}}

{{/*
Template used for resolving selector labels for graphqlApi component
*/}}
{{- define "smartface.graphqlApi.selectorLabels" }}
{{- include "smartface.selectorLabels" . }}
app.kubernetes.io/component: "graphqlApi"
{{- end -}}

{{/*
detector
*/}}
{{/*
Template used for resolving SF detector name
*/}}
{{- define "smartface.detector.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := .Values.detector.name -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Template used for resolving labels for detector component
*/}}
{{- define "smartface.detector.labels" }}
{{- include "smartface.labels" . }}
app.kubernetes.io/component: "detector"
{{- end -}}

{{/*
Template used for resolving selector labels for detector component
*/}}
{{- define "smartface.detector.selectorLabels" }}
{{- include "smartface.selectorLabels" . }}
app.kubernetes.io/component: "detector"
{{- end -}}

{{/*
extractor
*/}}
{{/*
Template used for resolving SF extractor name
*/}}
{{- define "smartface.extractor.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := .Values.extractor.name -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Template used for resolving labels for extractor component
*/}}
{{- define "smartface.extractor.labels" }}
{{- include "smartface.labels" . }}
app.kubernetes.io/component: "extractor"
{{- end -}}

{{/*
Template used for resolving selector labels for extractor component
*/}}
{{- define "smartface.extractor.selectorLabels" }}
{{- include "smartface.selectorLabels" . }}
app.kubernetes.io/component: "extractor"
{{- end -}}

{{/*
matcher
*/}}
{{/*
Template used for resolving SF matcher name
*/}}
{{- define "smartface.matcher.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := .Values.matcher.name -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Template used for resolving labels for matcher component
*/}}
{{- define "smartface.matcher.labels" }}
{{- include "smartface.labels" . }}
app.kubernetes.io/component: "matcher"
{{- end -}}

{{/*
Template used for resolving selector labels for matcher component
*/}}
{{- define "smartface.matcher.selectorLabels" }}
{{- include "smartface.selectorLabels" . }}
app.kubernetes.io/component: "matcher"
{{- end -}}

{{/*
liveness
*/}}
{{/*
Template used for resolving SF liveness name
*/}}
{{- define "smartface.liveness.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := .Values.liveness.name -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Template used for resolving labels for liveness component
*/}}
{{- define "smartface.liveness.labels" }}
{{- include "smartface.labels" . }}
app.kubernetes.io/component: "liveness"
{{- end -}}

{{/*
Template used for resolving selector labels for liveness component
*/}}
{{- define "smartface.liveness.selectorLabels" }}
{{- include "smartface.selectorLabels" . }}
app.kubernetes.io/component: "liveness"
{{- end -}}

{{/*
edgeStreamProcessor
*/}}
{{/*
Template used for resolving SF edgeStreamProcessor name
*/}}
{{- define "smartface.edgeStreamProcessor.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := .Values.edgeStreamProcessor.name -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Template used for resolving labels for edgeStreamProcessor component
*/}}
{{- define "smartface.edgeStreamProcessor.labels" }}
{{- include "smartface.labels" . }}
app.kubernetes.io/component: "edgeStreamProcessor"
{{- end -}}

{{/*
Template used for resolving selector labels for edgeStreamProcessor component
*/}}
{{- define "smartface.edgeStreamProcessor.selectorLabels" }}
{{- include "smartface.selectorLabels" . }}
app.kubernetes.io/component: "edgeStreamProcessor"
{{- end -}}

{{/*
edgeStreamsStateSync
*/}}
{{/*
Template used for resolving SF edgeStreamsStateSync name
*/}}
{{- define "smartface.edgeStreamsStateSync.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := .Values.edgeStreamsStateSync.name -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Template used for resolving labels for edgeStreamsStateSync component
*/}}
{{- define "smartface.edgeStreamsStateSync.labels" }}
{{- include "smartface.labels" . }}
app.kubernetes.io/component: "edgeStreamsStateSync"
{{- end -}}

{{/*
Template used for resolving selector labels for edgeStreamsStateSync component
*/}}
{{- define "smartface.edgeStreamsStateSync.selectorLabels" }}
{{- include "smartface.selectorLabels" . }}
app.kubernetes.io/component: "edgeStreamsStateSync"
{{- end -}}

{{/*
base
*/}}
{{/*
Template used for resolving SF base name
*/}}
{{- define "smartface.base.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := .Values.base.name -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Template used for resolving labels for base component
*/}}
{{- define "smartface.base.labels" }}
{{- include "smartface.labels" . }}
app.kubernetes.io/component: "base"
{{- end -}}

{{/*
Template used for resolving selector labels for base component
*/}}
{{- define "smartface.base.selectorLabels" }}
{{- include "smartface.selectorLabels" . }}
app.kubernetes.io/component: "base"
{{- end -}}

{{/*
faceMatcher
*/}}
{{/*
Template used for resolving SF faceMatcher name
*/}}
{{- define "smartface.faceMatcher.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := .Values.faceMatcher.name -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Template used for resolving labels for faceMatcher component
*/}}
{{- define "smartface.faceMatcher.labels" }}
{{- include "smartface.labels" . }}
app.kubernetes.io/component: "faceMatcher"
{{- end -}}

{{/*
Template used for resolving selector labels for faceMatcher component
*/}}
{{- define "smartface.faceMatcher.selectorLabels" }}
{{- include "smartface.selectorLabels" . }}
app.kubernetes.io/component: "faceMatcher"
{{- end -}}

{{/*
accessController
*/}}
{{/*
Template used for resolving SF accessController name
*/}}
{{- define "smartface.accessController.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := .Values.accessController.name -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
accessController auth
*/}}
{{/*
Template used for resolving SF accessController name
*/}}
{{- define "smartface.accessController.authServiceName" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := .Values.accessController.authServiceName -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}


{{/*
Template used for resolving labels for accessController component
*/}}
{{- define "smartface.accessController.labels" }}
{{- include "smartface.labels" . }}
app.kubernetes.io/component: "accessController"
{{- end -}}

{{/*
Template used for resolving selector labels for accessController component
*/}}
{{- define "smartface.accessController.selectorLabels" }}
{{- include "smartface.selectorLabels" . }}
app.kubernetes.io/component: "accessController"
{{- end -}}

{{/*
station
*/}}
{{/*
Template used for resolving SF station name
*/}}
{{- define "smartface.station.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := .Values.station.name -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Template used for resolving labels for station component
*/}}
{{- define "smartface.station.labels" }}
{{- include "smartface.labels" . }}
app.kubernetes.io/component: "station"
{{- end -}}

{{/*
Template used for resolving selector labels for station component
*/}}
{{- define "smartface.station.selectorLabels" }}
{{- include "smartface.selectorLabels" . }}
app.kubernetes.io/component: "station"
{{- end -}}

{{/*
streamDataDbWorker
*/}}
{{/*
Template used for resolving SF streamDataDbWorker name
*/}}
{{- define "smartface.streamDataDbWorker.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := .Values.streamDataDbWorker.name -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Template used for resolving labels for streamDataDbWorker component
*/}}
{{- define "smartface.streamDataDbWorker.labels" }}
{{- include "smartface.labels" . }}
app.kubernetes.io/component: "streamDataDbWorker"
{{- end -}}

{{/*
Template used for resolving selector labels for streamDataDbWorker component
*/}}
{{- define "smartface.streamDataDbWorker.selectorLabels" }}
{{- include "smartface.selectorLabels" . }}
app.kubernetes.io/component: "streamDataDbWorker"
{{- end -}}

{{/*
countlyPublisher
*/}}
{{/*
Template used for resolving SF countlyPublisher name
*/}}
{{- define "smartface.countlyPublisher.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := .Values.countlyPublisher.name -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Template used for resolving labels for countlyPublisher component
*/}}
{{- define "smartface.countlyPublisher.labels" }}
{{- include "smartface.labels" . }}
app.kubernetes.io/component: "countlyPublisher"
{{- end -}}

{{/*
Template used for resolving selector labels for countlyPublisher component
*/}}
{{- define "smartface.countlyPublisher.selectorLabels" }}
{{- include "smartface.selectorLabels" . }}
app.kubernetes.io/component: "countlyPublisher"
{{- end -}}

{{/*
RabbitMq
*/}}

{{/*
Template used for resolving RabbitMQ config map name
*/}}
{{- define "smartface.rabbitmq.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := "rabbitmq" -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Template used for resolving RabbitMQ config map name
*/}}
{{- define "smartface.rabbitmq.mqttName" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := "mqtt" -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
S3
*/}}

{{/*
Template used for resolving S3 config map name
*/}}
{{- define "smartface.s3.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := "s3" -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Template used for resolving Auth config map name
*/}}
{{- define "smartface.auth.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := "auth" -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Tests
*/}}

{{/*
Template used for resolving Watchlist tests name
*/}}
{{- define "smartface.watchlistTests.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := "watchlist-tests" -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Template used for resolving Watchlist tests with authentication name
*/}}
{{- define "smartface.authWatchlistTests.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := "watchlist-auth-tests" -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Template used for resolving Edge Stream tests name
*/}}
{{- define "smartface.edgeStreamTests.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := "edge-stream-tests" -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}

{{/*
Template used for resolving GraphQL tests name
*/}}
{{- define "smartface.graphQlTests.name" }}
{{- $prefix := include "smartface.name" . -}}
{{- $suffix := "graphql-tests" -}}
{{- printf "%s-%s" $prefix $suffix -}}
{{- end -}}
