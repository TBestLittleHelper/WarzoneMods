# War.app Mods
 Mods for War.app


# Workspaces

Each mod is it's own workspace. In each mod you will therefore want to have .vscode settings.json file, that incudes the annotations library. This will give you Types. To make luals work nicely, make sure you work in the workspace / mod folder and not from root. .

{
	"Lua.workspace.library": [
		"FILEPATH_TO_ANNOTATIONS"
	],
}
