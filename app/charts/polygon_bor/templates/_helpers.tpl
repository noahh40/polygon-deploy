{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "bor.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "bor.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "bor.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
bor statefullset annotations
*/}}
{{- define "bor.statefulset.annotations" -}}
{{- if .Values.persistence.snapshotValue -}}
snapshot: {{ .Values.persistence.snapshotValue }}
{{- end -}}
{{- end -}}

{{/*
bor args
*/}}
{{- define "bor.args" -}}

{{- $customArgs := list -}}



{{- $args := list -}}
{{- range $name := .Values.config_flags }}
{{- $args = append $args (printf "--%v" $name ) -}}
{{- end }}
{{- range $name, $value := .Values.config }}
{{- $args = append $args (printf "--%v=%v" $name $value) -}}
{{- end }}



{{- $args = append $args (printf "--http.port=%v"   .Values.httpRPC.port) -}}
{{- $args = append $args (printf "--http.vhosts=%v" .Values.httpRPC.vhosts) -}}
{{- $args = append $args (printf "--http.api=%v" .Values.httpRPC.api) -}}
{{- $args = append $args (printf "--ws.port=%v"     .Values.wsRPC.port) -}}
{{- $args = append $args (printf "--ws.api=%v"      .Values.wsRPC.api ) -}}
{{- $args = append $args (printf "--ws.origins=%v"     .Values.wsRPC.origins) -}}


{{- range $testnet := list "ropsten" "rinkeby" -}}
  {{- if eq ($testnet | get $.Values | toString) "true"  -}}
    {{- $args = prepend $args ($testnet | printf "--%s") -}}
  {{- end -}}
{{- end -}}

{{- range $k, $v := .Values.customArgs -}}
  {{- $customArgs = concat $customArgs (list ($k | printf "--%s") $v) -}}
{{- end -}}

{{- $mode := "snapshot" | get .Values | toString -}}
{{- if eq $mode "true" -}}
  {{- $args = append $args "--snapshot" -}}
{{- else if eq $mode "false" -}}
  {{- $args = append $args "--snapshot=false" -}}
{{- end -}}

{{- concat $args $customArgs | compact | toStrings | toYaml -}}

{{- end -}}
