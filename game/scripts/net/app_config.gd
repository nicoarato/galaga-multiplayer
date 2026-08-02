extends Node

const DEFAULT_BACKEND_URL := "http://127.0.0.1:3000"

var backend_url := DEFAULT_BACKEND_URL


func api_url(path: String) -> String:
	return "%s%s" % [backend_url, path]
