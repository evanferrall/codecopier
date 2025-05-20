import Danger

let danger = Danger()

let uiImportViolation = danger.git.modifiedFiles + danger.git.createdFiles
    .filter { $0.contains("CodeCopier/Sources/Services") }
    .flatMap { file -> [String] in
        guard let content = try? danger.utils.readFile(file) else { return [] }
        return content.split(separator: "\n").map(String.init).filter { $0.contains("import SwiftUI") || $0.contains("import AppKit") }
    }

if !uiImportViolation.isEmpty {
    fail("Services modules should not import UI frameworks")
}

