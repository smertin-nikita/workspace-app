{{/*
Deployment template
*/}}
{{- define "helm.deployment" }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "helm.name" . }}-{{ .name }}
  labels: {{- include "helm.labels" . | nindent 4 }}
spec:
  replicas: {{ .replicas | default .defaultValues.replicas }}
  revisionHistoryLimit: {{ .revisionHistoryLimit | default .defaultValues.revisionHistoryLimit }}
  selector:
    matchLabels:
      {{- include "helm.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "helm.selectorLabels" . | nindent 8 }}
        {{- include "helm.workloadLabels" . | nindent 8 }}
      {{- if .podAnnotations }}
      annotations:
        {{- toYaml .podAnnotations | nindent 8 }}
      {{- end }}
    spec:
      {{- if or .defaultValues.image.pullSecrets ((.imageOverride).pullSecrets) }}
      imagePullSecrets:
        {{- ((.imageOverride).pullSecrets) | default .defaultValues.image.pullSecrets | toYaml | nindent 8}}
      {{- end }}
      serviceAccountName: {{ include "helm.serviceAccountName" .}}
      {{- $schedulingRules := .schedulingRules | default dict }}
      {{- if or .defaultValues.schedulingRules.nodeSelector $schedulingRules.nodeSelector}}
      nodeSelector:
        {{- $schedulingRules.nodeSelector | default .defaultValues.schedulingRules.nodeSelector | toYaml | nindent 8 }}
      {{- end }}
      {{- if or .defaultValues.schedulingRules.affinity $schedulingRules.affinity}}
      affinity:
        {{- $schedulingRules.affinity | default .defaultValues.schedulingRules.affinity | toYaml | nindent 8 }}
      {{- end }}
      {{- if or .defaultValues.schedulingRules.tolerations $schedulingRules.tolerations}}
      tolerations:
        {{- $schedulingRules.tolerations | default .defaultValues.schedulingRules.tolerations | toYaml | nindent 8 }}
      {{- end }}
      {{- if or .defaultValues.podSecurityContext .podSecurityContext }}
      securityContext:
        {{- .podSecurityContext | default .defaultValues.podSecurityContext | toYaml | nindent 8 }}
      {{- end}}
      containers:
        - name: {{ .name }}
          image: '{{ ((.imageOverride).repository) | default .defaultValues.image.repository }}:{{ ((.imageOverride).tag) | default (printf "%s-%s" (default .Chart.AppVersion .defaultValues.image.tag) (replace "-" "" .name)) }}'
          imagePullPolicy: {{ ((.imageOverride).pullPolicy) | default .defaultValues.image.pullPolicy }}
          {{- if .command }}
          command:
            {{- .command | toYaml | nindent 12 -}}
          {{- end }}
          {{- if or .ports .service}}
          ports:
            {{- include "helm.pod.ports" . | nindent 12 }}
          {{- end }}
          env:
            {{- include "helm.pod.env" . | nindent 12 }}
          resources:
            {{- .resources | toYaml | nindent 12 }}
          {{- if or .defaultValues.securityContext .securityContext }}
          securityContext:
            {{- .securityContext | default .defaultValues.securityContext | toYaml | nindent 12 }}
          {{- end}}
          {{- if .livenessProbe }}
          livenessProbe:
            {{- .livenessProbe | toYaml | nindent 12 }}
          {{- end }}
          {{- if .readinessProbe }}
          readinessProbe:
            {{- .readinessProbe | toYaml | nindent 12 }}
          {{- end }}
          volumeMounts:
          {{- range .mountedConfigMaps }}
            - name: {{ .name | lower }}
              mountPath: {{ .mountPath }}
              {{- if .subPath }}
              subPath: {{ .subPath }}
              {{- end }}
          {{- end }}
          {{- range .mountedEmptyDirs }}
            - name: {{ .name | lower }}
              mountPath: {{ .mountPath }}
              {{- if .subPath }}
              subPath: {{ .subPath }}
              {{- end }}
          {{- end }}
        {{- range .sidecarContainers }}
        {{- $sidecar := set . "name" (.name | lower)}}
        {{- $sidecar = set . "Chart" $.Chart }}
        {{- $sidecar = set . "Release" $.Release }}
        {{- $sidecar = set . "defaultValues" $.defaultValues }}
        - name: {{ .name   }}
          image: '{{ ((.imageOverride).repository) | default .defaultValues.image.repository }}:{{ ((.imageOverride).tag) | default (printf "%s-%s" (default .Chart.AppVersion .defaultValues.image.tag) (replace "-" "" .name)) }}'
          imagePullPolicy: {{ ((.imageOverride).pullPolicy) | default .defaultValues.image.pullPolicy }}
          {{- if .command }}
          command:
            {{- .command | toYaml | nindent 12 -}}
          {{- end }}
          {{- if or .ports .service }}
          ports:
            {{- include "helm.pod.ports" . | nindent 12 }}
          {{- end }}
          env:
            {{- include "helm.pod.env" . | nindent 12 }}
          {{- if .resources }}
          resources:
            {{- .resources | toYaml | nindent 12 }}
          {{- end }}
          {{- if or .defaultValues.securityContext .securityContext }}
          securityContext:
            {{- .securityContext | default .defaultValues.securityContext | toYaml | nindent 12 }}
          {{- end}}
          {{- if .livenessProbe }}
          livenessProbe:
            {{- .livenessProbe | toYaml | nindent 12 }}
          {{- end }}
          {{- if .volumeMounts }}
          volumeMounts:
            {{- .volumeMounts | toYaml | nindent 12 }}
          {{- end }}
        {{- end }}
      {{- if .initContainers }}
      initContainers:
        {{- tpl (toYaml .initContainers) . | nindent 8 }}
      {{- end}}
      volumes:
        {{- range .mountedConfigMaps }}
        - name: {{ .name | lower}}
          configMap:
            {{- if .existingConfigMap }}
            name: {{ tpl .existingConfigMap $ }}
            {{- else }}
            name: {{ include "helm.name" $ }}-{{ $.name }}-{{ .name | lower }}
            {{- end }}
        {{- end }}
        {{- range .mountedEmptyDirs }}
        - name: {{ .name | lower}}
          emptyDir: {}
        {{- end }}
        {{- if .additionalVolumes }}
        {{- tpl (toYaml .additionalVolumes) . | nindent 8 }}
        {{- end }}
{{- end }}
