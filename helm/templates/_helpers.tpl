{{/*
Expand the name of the chart.
*/}}
{{- define "helm.name" -}}
{{- default .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "helm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{/*

{{/*
Common labels
*/}}
{{- define "helm.labels" -}}
helm.sh/chart: {{ include "helm.chart" . }}
{{ include "helm.selectorLabels" . }}
{{ include "helm.workloadLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/part-of: {{ .Release.Namespace }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
Workload (Pod) labels
*/}}
{{- define "helm.workloadLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .name }}
app.kubernetes.io/component: {{ .name}}
app.kubernetes.io/name: {{ include "helm.name" . }}-{{ .name }}
{{- else }}
app.kubernetes.io/name: {{ include "helm.name" . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helm.selectorLabels" -}}
{{- if .name }}
nekitsmertin/name: {{ include "helm.name" . }}-{{ .name }}
{{- else }}
nekitsmertin/name: {{ include "helm.name" . }}
{{- end }}
{{- end }}

{{- define "helm.envOverriden" -}}
{{- $mergedEnvs := list }}
{{- $envOverrides := default (list) .envOverrides }}

{{- range .env }}
{{-   $currentEnv := . }}
{{-   $hasOverride := false }}
{{-   range $envOverrides }}
{{-     if eq $currentEnv.name .name }}
{{-       $mergedEnvs = append $mergedEnvs . }}
{{-       $envOverrides = without $envOverrides . }}
{{-       $hasOverride = true }}
{{-     end }}
{{-   end }}
{{-   if not $hasOverride }}
{{-     $mergedEnvs = append $mergedEnvs $currentEnv }}
{{-   end }}
{{- end }}
{{- $mergedEnvs = concat $mergedEnvs $envOverrides }}
{{- mustToJson $mergedEnvs }}
{{- end }}


Create the name of the service account to use
*/}}
{{- define "helm.serviceAccountName" -}}
{{- if .serviceAccount.create }}
{{- default (include "helm.name" .) .serviceAccount.name }}
{{- else }}
{{- default "default" .serviceAccount.name }}
{{- end }}
{{- end }}