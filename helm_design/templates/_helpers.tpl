{{/*
Expand the name of the chart.
*/}}
{{- define "helm_design.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "helm_design.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "helm_design.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "helm_design.labels" -}}
helm.sh/chart: {{ include "helm_design.chart" . }}
{{ include "helm_design.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helm_design.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helm_design.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "helm_design.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "helm_design.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
This is created for node affinity
*/}}

{{- define "Node_affinity" }}

nodeSelector:
  app: {{ .Values.idpapp.nodeSelector.app }}
tolerations:
  - key: {{ .Values.idpapp.tolerations.key }}
    operator: Equal
    value: {{ .Values.idpapp.tolerations.value }}
    effect: NoSchedule
{{- end }}


{{/*
Below is the security context
*/}}

{{- define "securityContext" }}
securityContext:
  allowPrivilegeEscalation: false
  seccompProfile:
    type: RuntimeDefault
  runAsNonRoot: true
  runAsUser: 5000
  capabilities:
    drop:
      - ALL
    add:
      - NET_BIND_SERVICE

{{- end }}


{{/*
Kubernetes probes
*/}}

{{- define "probes" }}

readinessProbe:
  tcpSocket:
    port: {{ .containerPort }}
livenessProbe:
  tcpSocket:
    port: {{ .containerPort }}

{{- end }}
