// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
int foo(int x, int y) {
  var z = x + y;
  return z << 4;
}

main() {
  foo(4, 5);
  foo(6, 7);
}
