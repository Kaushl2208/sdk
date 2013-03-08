// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test_utils;

import 'dart:async';
import 'dart:io';
import 'dart:json' as json;
import 'dart:uri';

import 'package:unittest/unittest.dart';
import '../lib/src/byte_stream.dart';
import '../lib/http.dart' as http;
import '../lib/src/utils.dart';

/// The current server instance.
HttpServer _server;

/// The URL for the current server instance.
Uri get serverUrl => Uri.parse('http://localhost:${_server.port}');

/// A dummy URL for constructing requests that won't be sent.
Uri get dummyUrl => Uri.parse('http://dartlang.org/');

/// Starts a new HTTP server.
Future startServer() {
  return HttpServer.bind("127.0.0.1", 0).then((s) {
    _server = s;
    s.listen((request) {
      var path = request.uri.path;
      var response = request.response;

      if (path == '/error') {
        response.statusCode = 400;
        response.contentLength = 0;
        response.close();
        return;
      }

      if (path == '/loop') {
        var n = int.parse(request.uri.query);
        response.statusCode = 302;
        response.headers.set('location',
            serverUrl.resolve('/loop?${n + 1}').toString());
        response.contentLength = 0;
        response.close();
        return;
      }

      if (path == '/redirect') {
        response.statusCode = 302;
        response.headers.set('location', serverUrl.resolve('/').toString());
        response.contentLength = 0;
        response.close();
        return;
      }

      new ByteStream(request).toBytes().then((requestBodyBytes) {
        var outputEncoding;
        var encodingName = request.queryParameters['response-encoding'];
        if (encodingName != null) {
          outputEncoding = requiredEncodingForCharset(encodingName);
        } else {
          outputEncoding = Encoding.ASCII;
        }

        response.headers.contentType =
            new ContentType(
                "application", "json", charset: outputEncoding.name);
        response.headers.set('single', 'value');

        var requestBody;
        if (requestBodyBytes.isEmpty) {
          requestBody = null;
        } else if (request.headers.contentType.charset != null) {
          var encoding = requiredEncodingForCharset(
              request.headers.contentType.charset);
          requestBody = decodeString(requestBodyBytes, encoding);
        } else {
          requestBody = requestBodyBytes;
        }

        var content = {
          'method': request.method,
          'path': request.uri.path,
          'headers': {}
        };
        if (requestBody != null) content['body'] = requestBody;
        request.headers.forEach((name, values) {
          // These headers are automatically generated by dart:io, so we don't
          // want to test them here.
          if (name == 'cookie' || name == 'host') return;

          content['headers'][name] = values;
        });

        var body = json.stringify(content);
        response.contentLength = body.length;
        response.write(body);
        response.close();
      });
    });
  });
}

/// Stops the current HTTP server.
void stopServer() {
  _server.close();
  _server = null;
}

/// Removes eight spaces of leading indentation from a multiline string.
///
/// Note that this is very sensitive to how the literals are styled. They should
/// be:
///     '''
///     Text starts on own line. Lines up with subsequent lines.
///     Lines are indented exactly 8 characters from the left margin.
///     Close is on the same line.'''
///
/// This does nothing if text is only a single line.
// TODO(nweiz): Make this auto-detect the indentation level from the first
// non-whitespace line.
String cleanUpLiteral(String text) {
  var lines = text.split('\n');
  if (lines.length <= 1) return text;

  for (var j = 0; j < lines.length; j++) {
    if (lines[j].length > 8) {
      lines[j] = lines[j].substring(8, lines[j].length);
    } else {
      lines[j] = '';
    }
  }

  return lines.join('\n');
}

/// A matcher that matches JSON that parses to a value that matches the inner
/// matcher.
Matcher parse(matcher) => new _Parse(matcher);

class _Parse extends BaseMatcher {
  final Matcher _matcher;

  _Parse(this._matcher);

  bool matches(item, MatchState matchState) {
    if (item is! String) return false;

    var parsed;
    try {
      parsed = json.parse(item);
    } catch (e) {
      return false;
    }

    return _matcher.matches(parsed, matchState);
  }

  Description describe(Description description) {
    return description.add('parses to a value that ')
      .addDescriptionOf(_matcher);
  }
}

/// A matcher for HttpExceptions.
const isHttpException = const _HttpException();

/// A matcher for functions that throw HttpException.
const Matcher throwsHttpException =
    const Throws(isHttpException);

class _HttpException extends TypeMatcher {
  const _HttpException() : super("HttpException");
  bool matches(item, MatchState matchState) => item is HttpException;
}

/// A matcher for RedirectLimitExceededExceptions.
const isRedirectLimitExceededException =
    const _RedirectLimitExceededException();

/// A matcher for functions that throw RedirectLimitExceededException.
const Matcher throwsRedirectLimitExceededException =
    const Throws(isRedirectLimitExceededException);

class _RedirectLimitExceededException extends TypeMatcher {
  const _RedirectLimitExceededException() :
      super("RedirectLimitExceededException");

  bool matches(item, MatchState matchState) =>
    item is RedirectLimitExceededException;
}

/// A matcher for SocketIOExceptions.
const isSocketIOException = const _SocketIOException();

/// A matcher for functions that throw SocketIOException.
const Matcher throwsSocketIOException =
    const Throws(isSocketIOException);

class _SocketIOException extends TypeMatcher {
  const _SocketIOException() : super("SocketIOException");
  bool matches(item, MatchState matchState) => item is SocketIOException;
}
