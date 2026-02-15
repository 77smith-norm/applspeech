import Testing
@testable import ApplSpeech

@Suite("Command Parsing")
struct CommandParserTests {
  @Test("Empty args -> help")
  func emptyArgs() {
    #expect(CommandParser.parse(arguments: []) == .help)
  }

  @Test("--help -> help")
  func longHelp() {
    #expect(CommandParser.parse(arguments: ["--help"]) == .help)
  }

  @Test("transcribe <file> -> transcribe command")
  func transcribeWithFile() {
    #expect(CommandParser.parse(arguments: ["transcribe", "a.wav"]) == .transcribe(filePath: "a.wav"))
  }

  @Test("transcribe -> transcribe with missing file")
  func transcribeMissingFile() {
    #expect(CommandParser.parse(arguments: ["transcribe"]) == .transcribe(filePath: nil))
  }

  @Test("Unknown args -> unknown")
  func unknownArgs() {
    #expect(CommandParser.parse(arguments: ["wat"]) == .unknown(arguments: ["wat"]))
  }
}

