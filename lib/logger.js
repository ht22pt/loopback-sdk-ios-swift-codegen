
const fs = require('fs');
const moment = require('moment');
const path = require('path');
const { createLogger, format, transports } = require('winston');

const { combine, timestamp, json, printf, splat, colorize } = format;
const myFormat = printf(info => `${info.timestamp} ${info.level}: ${info.message}`);

// { error: 0, warn: 1, info: 2, verbose: 3, debug: 4, silly: 5 }
const PROJECT_ROOT = path.join(__dirname, '..');

const myTimeFormat = function timeFormat () {
  return moment().format('DD/MM/YYYY @ HH:mm:ss.SSS');
};

// TODO: Check logger for worker here
let logDir;
if (typeof process.env.workerId === 'undefined') {
  logDir = 'logs';
} else {
  logDir = `worker/${process.env.workerId}/logs`;
}

// Create the log directory if it does not exist
if (!fs.existsSync(logDir)) {
  fs.mkdir(logDir);
}

const logger = createLogger({
  transports: [
    new transports.File({
      level: 'error',
      format: combine(
        splat(),
        timestamp({ format: myTimeFormat }),
        myFormat,
      ),
      filename: `${logDir}/error-log.log`,
      handleExceptions: true,
      maxsize: 10485760, // 10MB
      maxFiles: 20,
      colorize: false,
      timestamp: myTimeFormat,
    }),
    new transports.File({
      level: 'debug',
      format: combine(
        splat(),
        timestamp({ format: myTimeFormat }),
        myFormat,
      ),
      filename: `${logDir}/all-log.log`,
      handleExceptions: true,
      maxsize: 10485760, // 10MB
      maxFiles: 20,
      colorize: false,
      timestamp: myTimeFormat,
    }),
    new transports.Console({
      level: 'debug',
      handleExceptions: true,
      format: combine(
        splat(),
        colorize(),
        timestamp({ format: myTimeFormat }),
        myFormat,
      ),
    }),
  ],
  exceptionHandlers: [
    new transports.File({
      filename: `${logDir}/exceptions.log`,
      format: combine(
        splat(),
        timestamp({ format: myTimeFormat }),
        myFormat,
        json(),
      ),
      maxsize: 10485760, // 10MB
      maxFiles: 20,
    }),
  ],
  exitOnError: false,
});

// A custom logger interface that wraps winston, making it easy to instrument
// code and still possible to replace winston in the future.
logger.stream = {
  write: function (message, encoding) {
    logger.info([
      message,
      encoding,
    ]);
  },
};

module.exports.debug = module.exports.log = function () {
  logger.debug.apply(logger, formatLogArguments(arguments));
};

module.exports.info = function () {
  logger.info.apply(logger, formatLogArguments(arguments));
};

module.exports.warn = function () {
  logger.warn.apply(logger, formatLogArguments(arguments));
};

module.exports.error = function () {
  logger.error.apply(logger, formatLogArguments(arguments));
};

// module.exports = logger;
module.exports.stream = logger.stream;
/*
module.exports.stream = {
  write: function (message, encoding) {
    logger.info([
      message,
      encoding,
    ]);
  },
};
*/

/**
 * Attempts to add file and line number info to the given log arguments.
 */
function formatLogArguments (args) {
  args = Array.prototype.slice.call(args);

  let stackInfo = getStackInfo(1);

  if (stackInfo) {
    // get file path relative to project root
    let calleeStr = '(' + stackInfo.relativePath + ':' + stackInfo.line + ')';

    if (typeof (args[0]) === 'string') {
      args[0] = calleeStr + ' ' + args[0];
    } else {
      args.unshift(calleeStr);
    }
  }

  return args;
}

/**
 * Parses and returns info about the call stack at the given index.
 */
function getStackInfo (stackIndex) {
  // get call stack, and analyze it
  // get all file, method, and line numbers
  let stacklist = (new Error()).stack.split('\n').slice(3);

  // stack trace format:
  // http://code.google.com/p/v8/wiki/JavaScriptStackTraceApi
  // do not remove the regex expresses to outside of this method (due to a BUG in node.js)
  let stackReg = /at\s+(.*)\s+\((.*):(\d*):(\d*)\)/gi;
  let stackReg2 = /at\s+()(.*):(\d*):(\d*)/gi;

  let s = stacklist[stackIndex] || stacklist[0];
  let sp = stackReg.exec(s) || stackReg2.exec(s);

  if (sp && sp.length === 5) {
    return {
      method: sp[1],
      relativePath: path.relative(PROJECT_ROOT, sp[2]),
      line: sp[3],
      pos: sp[4],
      file: path.basename(sp[2]),
      stack: stacklist.join('\n'),
    };
  }
}
