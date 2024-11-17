{{/*
Secret template
*/}}
{{- define "helm.secret" }}
{{- range .secrets }}
{{- if .secret }}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "helm.name" $ }}-{{ $.name }}-{{ .name | lower }}
  labels:
    {{- include "helm.labels" $ | nindent 4 }}
type: Opaque
stringData:
  {{- .secret | toYaml | nindent 2}}
{{- end}}
{{- end}}
{{- end}}
