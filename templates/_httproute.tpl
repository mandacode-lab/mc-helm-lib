{{/*
Generic HTTPRoute template for Gateway API
Usage: {{ include "mc-helm-lib.httproute" (dict
  "component" "admin"
  "config" .Values.admin
  "root" $
)}}
*/}}
{{- define "mc-helm-lib.httproute" -}}
{{- $component := .component -}}
{{- $config := .config -}}
{{- $root := .root -}}
{{- if and $config.enabled $config.httpRoute.enabled }}
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ include "mc-helm-lib.fullname" $root }}-{{ $component }}
  labels:
    {{- include "mc-helm-lib.labels" (dict "component" $component "root" $root) | nindent 4 }}
  {{- with $config.httpRoute.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- with $config.httpRoute.parentRefs }}
  parentRefs:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $config.httpRoute.hostnames }}
  hostnames:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  rules:
  {{- range $config.httpRoute.rules }}
  - matches:
    {{- toYaml .matches | nindent 4 }}
    {{- with .filters }}
    filters:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    backendRefs:
    - name: {{ include "mc-helm-lib.fullname" $root }}-{{ $component }}
      port: {{ $config.service.port }}
  {{- end }}
{{- end }}
{{- end }}
