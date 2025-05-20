import ArgumentParser

@main
struct CodeCopierCLI: ParsableCommand {
    mutating func run() throws {
        print("CodeCopier CLI")
    }
}
