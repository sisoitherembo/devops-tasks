{{- define "nginx-app.labels" -}}
app: {{ .Release.Name | quote }}
env: {{ .Values.application.env | quote }}
{{- end -}}