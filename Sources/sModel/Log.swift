import Foundation

public enum LogLevel: Int {
  case debug = 0, verbose, info, warn, error, exception
}

public protocol Logger {
  func debug(_ message: String, file: StaticString, line: UInt)
  func verbose(_ message: String, file: StaticString, line: UInt)
  func error(_ message: String, file: StaticString, line: UInt)
  func warn(_ message: String, file: StaticString, line: UInt)
  func info(_ message: String, file: StaticString, line: UInt)
  func exception(_ error: NSError, file: StaticString, line: UInt)
}

public class Log: Logger {
  public static var logger: Logger = Log()
  public static var logLevel = LogLevel.debug
  
  public class func debug(_ message: String, file: StaticString = #file, line: UInt = #line) {
    guard shouldLog(requestLevel: .debug) else { return }
    logger.debug(message, file: file, line: line)
  }
  public class func verbose(_ message: String, file: StaticString = #file, line: UInt = #line) {
    guard shouldLog(requestLevel: .verbose) else { return }
    logger.verbose(message, file: file, line: line)
  }
  public class func error(_ message: String, file: StaticString = #file, line: UInt = #line) {
    guard shouldLog(requestLevel: .error) else { return }
    logger.error(message, file: file, line: line)
  }
  public class func warn(_ message: String, file: StaticString = #file, line: UInt = #line) {
    guard shouldLog(requestLevel: .warn) else { return }
    logger.warn(message, file: file, line: line)
  }
  public class func info(_ message: String, file: StaticString = #file, line: UInt = #line) {
    guard shouldLog(requestLevel: .info) else { return }
    logger.info(message, file: file, line: line)
  }
  public class func exception(_ error: NSError, file: StaticString = #file, line: UInt = #line) {
    guard shouldLog(requestLevel: .exception) else { return }
    logger.exception(error, file: file, line: line)
  }
  
  private class func shouldLog(requestLevel: LogLevel) -> Bool {
    guard requestLevel.rawValue >= logLevel.rawValue else { return false }
    return true
  }
  
  public func debug(_ message: String, file: StaticString, line: UInt) {
    print("D:\(file):\(line): \(message)")
  }
  public func verbose(_ message: String, file: StaticString, line: UInt) {
    print("V:\(file):\(line): \(message)")
  }
  public func error(_ message: String, file: StaticString, line: UInt) {
    print("E:\(file):\(line): \(message)")
  }
  public func warn(_ message: String, file: StaticString, line: UInt) {
    print("W:\(file):\(line): \(message)")
  }
  public func info(_ message: String, file: StaticString, line: UInt) {
    print("I:\(file):\(line): \(message)")
  }
  public func exception(_ error: NSError, file: StaticString, line: UInt) {
    self.error(error.localizedDescription, file: file, line: line)
  }
}
