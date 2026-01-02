# mc-helm-lib

Reusable Helm library chart providing standard Kubernetes resource templates.

## Templates

- `mc-helm-lib.deployment` - Deployment with config injection support
- `mc-helm-lib.service` - Service
- `mc-helm-lib.hpa` - HorizontalPodAutoscaler

## Installation

Add to your `Chart.yaml`:

```yaml
dependencies:
  - name: mc-helm-lib
    version: 0.1.0
    repository: "file://../mc-helm-lib"
```

Run: `helm dependency update`

## Usage

### Deployment

```yaml
# templates/deployment.yaml
{{ include "mc-helm-lib.deployment" (dict
  "component" "api"
  "config" .Values.api
  "root" $
) }}
```

### Deployment with ConfigMap/Secret Injection

```yaml
# templates/configs.yaml
{{- define "myapp.config" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "myapp.fullname" . }}-config
data:
  HTTP_PORT: "8080"
{{- end -}}

{{ include "myapp.config" . }}

---
# templates/deployment.yaml
{{ include "mc-helm-lib.deployment" (dict
  "component" "api"
  "config" .Values.api
  "configRefs" (list
    (dict
      "type" "configMap"
      "name" (printf "%s-config" (include "myapp.fullname" $))
      "template" "myapp.config"
      "params" $
    )
  )
  "root" $
) }}
```

**How it works:**
- `type`: "configMap" or "secret"
- `name`: Resource name for envFrom injection
- `template`: Template name for checksum calculation
- `params`: Parameters passed to template for checksum

Config changes trigger automatic pod restarts via checksum annotations.

### Service

```yaml
{{ include "mc-helm-lib.service" (dict
  "component" "api"
  "config" .Values.api
  "root" $
) }}
```

### HPA

```yaml
{{ include "mc-helm-lib.hpa" (dict
  "component" "api"
  "config" .Values.api
  "root" $
) }}
```

## Values Structure

```yaml
api:
  enabled: true
  replicaCount: 2

  image:
    repository: myregistry/myapp
    tag: "1.0.0"
    pullPolicy: IfNotPresent

  service:
    type: ClusterIP
    port: 80
    targetPort: 8080

  autoscaling:
    enabled: false
    minReplicas: 2
    maxReplicas: 10
    targetCPUUtilizationPercentage: 80

  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi

  livenessProbe:
    httpGet:
      path: /health
      port: http

  readinessProbe:
    httpGet:
      path: /ready
      port: http

  podSecurityContext: {}
  securityContext: {}
  podAnnotations: {}
  podLabels: {}
```

## Helper Functions

- `mc-helm-lib.name`
- `mc-helm-lib.fullname`
- `mc-helm-lib.chart`
- `mc-helm-lib.labels` (supports component)
- `mc-helm-lib.selectorLabels` (supports component)
- `mc-helm-lib.serviceAccountName`
