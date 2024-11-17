{{/*
ConfigMap template
*/}}
{{- define "helm.configmap" }}
{{- range .mountedConfigMaps }}
{{- if .data }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "helm.name" $ }}-{{ $.name }}-{{ .name | lower }}
  labels:
    {{- include "helm.labels" $ | nindent 4 }}
data:
  {{- .data | toYaml | nindent 2}}
{{- end}}
{{- end}}
{{- end}}