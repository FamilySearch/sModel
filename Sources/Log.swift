import Foundation

public enum LogLevel: Int {
  case debug = 0, verbose, info, warn, error, exception
}

public protocol Logger {
  func debug(_ message: String)
  func verbose(_ message: String)
  func error(_ message: String)
  func warn(_ message: String)
  func info(_ message: String)
  func exception(_ error: NSError)
}

public class Log: Logger {
  public static var logger: Logger = Log()
  public static var logLevel = LogLevel.debug
  
  public class func debug(_ message: String) {
    guard shouldLog(requestLevel: .verbose) else { return }
    logger.debug(message)
  }
  public class func verbose(_ message: String) {
    guard shouldLog(requestLevel: .verbose) else { return }
    logger.verbose(message)
  }
  public class func error(_ message: String) {
    guard shouldLog(requestLevel: .error) else { return }
    logger.error(message)
  }
  public class func warn(_ message: String) {
    guard shouldLog(requestLevel: .warn) else { return }
    logger.warn(message)
  }
  public class func info(_ message: String) {
    guard shouldLog(requestLevel: .info) else { return }
    logger.info(message)
  }
  public class func exception(_ error: NSError) {
    guard shouldLog(requestLevel: .exception) else { return }
    logger.exception(error)
  }
  
  private class func shouldLog(requestLevel: LogLevel) -> Bool {
    guard requestLevel.rawValue >= logLevel.rawValue else { return false }
    return true
  }
  
  public func debug(_ message: String) {
    print("D: \(message)")
  }
  public func verbose(_ message: String) {
    debug(message)
  }
  public func error(_ message: String) {
    print("E: \(message)")
  }
  public func warn(_ message: String) {
    print("W: \(message)")
  }
  public func info(_ message: String) {
    print("I: \(message)")
  }
  public func exception(_ error: NSError) {
    self.error(error.localizedDescription)
  }
}
