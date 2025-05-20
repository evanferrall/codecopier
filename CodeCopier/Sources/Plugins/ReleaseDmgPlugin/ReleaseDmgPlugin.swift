import PackagePlugin

@main
struct ReleaseDmgPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        return []
    }
}
