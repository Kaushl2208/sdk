// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/*class: global#Map:needsArgs,indirectTest,explicit=[Map]*/
/*class: global#LinkedHashMap:needsArgs,deps=[Map],indirectTest,explicit=[LinkedHashMap<LinkedHashMap.K,LinkedHashMap.V>],implicit=[LinkedHashMap.K,LinkedHashMap.V]*/
/*class: global#JsLinkedHashMap:needsArgs,deps=[LinkedHashMap],test,explicit=[JsLinkedHashMap.K,JsLinkedHashMap.V,JsLinkedHashMap<JsLinkedHashMap.K,JsLinkedHashMap.V>,void Function(JsLinkedHashMap.K,JsLinkedHashMap.V)],implicit=[JsLinkedHashMap.K,JsLinkedHashMap.V]*/
/*class: global#double:explicit=[double],implicit=[double],required,checks=[double,num,Object]*/

main() {
  <int, double>{}[0] = 0.5;
}
