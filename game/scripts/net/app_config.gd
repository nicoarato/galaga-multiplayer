extends Node

const DEFAULT_BACKEND_URL := "http://127.0.0.1:3000"

var backend_url := DEFAULT_BACKEND_URL


func api_url(path: String) -> String:
	return "%s%s" % [backend_url, path]


func ws_url(path: String) -> String:
	if backend_url.begins_with("https://"):
		return "wss://%s%s" % [backend_url.trim_prefix("https://"), path]

	if backend_url.begins_with("http://"):
		return "ws://%s%s" % [backend_url.trim_prefix("http://"), path]

	return "%s%s" % [backend_url, path]
