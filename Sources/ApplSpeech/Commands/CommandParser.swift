import Foundation

enum ApplSpeechCommand: Equatable {
  case help
  case transcribe(filePath: String?)
  case unknown(arguments: [String])
}

enum CommandParser {
  static func parse(arguments: [String]) -> ApplSpeechCommand {
    if arguments.isEmpty
      || arguments.contains("--help")
      || arguments.contains("-h")
      || arguments.first == "help"
    {
      return .help
    }

    if arguments.first == "transcribe" {
      return .transcribe(filePath: arguments.dropFirst().first)
    }

    return .unknown(arguments: arguments)
  }
}

