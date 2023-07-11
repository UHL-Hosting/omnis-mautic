{{/* vim: set filetype=mustache: */}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "mautic.mariadb.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "mariadb" "chartValues" .Values.mariadb "context" $) -}}
{{- end -}}

{{/*
Return the proper Mautic image name
*/}}
{{- define "mautic.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "mautic.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.image) "global" .Values.global) -}}
{{- end -}}

{{/*
 Create the name of the service account to use
 */}}
{{- define "mautic.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the MariaDB Hostname
*/}}
{{- define "mautic.databaseHost" -}}
{{- if .Values.mariadb.enabled }}
    {{- if eq .Values.mariadb.architecture "replication" }}
        {{- printf "%s-primary" (include "mautic.mariadb.fullname" .) | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
        {{- printf "%s" (include "mautic.mariadb.fullname" .) -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.host -}}
{{- end -}}
{{- end -}}

{{/*
Return the MariaDB Port
*/}}
{{- define "mautic.databasePort" -}}
{{- if .Values.mariadb.enabled }}
    {{- printf "3306" -}}
{{- else -}}
    {{- printf "%d" (.Values.externalDatabase.port | int ) -}}
{{- end -}}
{{- end -}}

{{/*
Return the MariaDB Database Name
*/}}
{{- define "mautic.databaseName" -}}
{{- if .Values.mariadb.enabled }}
    {{- printf "%s" .Values.mariadb.auth.database -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.database -}}
{{- end -}}
{{- end -}}

{{/*
Return the MariaDB User
*/}}
{{- define "mautic.databaseUser" -}}
{{- if .Values.mariadb.enabled }}
    {{- printf "%s" .Values.mariadb.auth.username -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.user -}}
{{- end -}}
{{- end -}}

{{/*
Return the MariaDB Secret Name
*/}}
{{- define "mautic.databaseSecretName" -}}
{{- if .Values.mariadb.enabled }}
    {{- if .Values.mariadb.auth.existingSecret -}}
        {{- printf "%s" .Values.mariadb.auth.existingSecret -}}
    {{- else -}}
        {{- printf "%s" (include "mautic.mariadb.fullname" .) -}}
    {{- end -}}
{{- else if .Values.externalDatabase.existingSecret -}}
    {{- include "common.tplvalues.render" (dict "value" .Values.externalDatabase.existingSecret "context" $) -}}
{{- else -}}
    {{- printf "%s-externaldb" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}
