{{/*
Generic Service template
Usage: {{ include "mc-helm-lib.service" (dict
  "component" "admin"
  "config" .Values.admin
  "root" $
)}}
*/}}
{{- define "mc-helm-lib.service" -}}
{{- $component := .component -}}
{{- $config := .config -}}
{{- $root := .root -}}
{{- if $config.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "mc-helm-lib.fullname" $root }}-{{ $component }}
  labels:
    {{- include "mc-helm-lib.labels" (dict "component" $component "root" $root) | nindent 4 }}
  {{- with $config.service.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  type: {{ $config.service.type }}
  ports:
  - port: {{ $config.service.port }}
    targetPort: http
    protocol: TCP
    name: http
  selector:
    {{- include "mc-helm-lib.selectorLabels" (dict "component" $component "root" $root) | nindent 4 }}
{{- end }}
{{- end }}
