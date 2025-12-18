# WarzoneMods
 Mods for Warzone.com


# Workspace

You will want to use types. Make sure to add the annotation to the workspace. It's also common for warzone mods to have many mods in the same git repo. To make this work nicely, we make the workspace ignore all folders in .vscode/settings.json and explicitly enable them in each mod's dedicated folder.

Root :
{
	"Lua.workspace.library": [
		"FILEPATH_TO_ANNOTATIONS"
	],
	"Lua.workspace.ignoreDir": [
		"**"
	]
}
Mod :
{
	"Lua.workspace.ignoreDir": []
}
