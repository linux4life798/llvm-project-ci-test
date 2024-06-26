// RUN: mlir-opt %s -pass-pipeline="builtin.module(func.func(linalg-detensorize{aggressive-mode}))" | FileCheck %s -check-prefix=DET-ALL
// RUN: mlir-opt %s -pass-pipeline="builtin.module(func.func(linalg-detensorize))" | FileCheck %s -check-prefix=DET-CF

#map0 = affine_map<() -> ()>

#attrs = {
  indexing_maps = [#map0, #map0, #map0],
  iterator_types = []
}

func.func @main(%farg0: tensor<i32>, %farg1: tensor<i32>) -> tensor<i32> attributes {} {
  cf.br ^bb1(%farg0 : tensor<i32>)

^bb1(%0: tensor<i32>):  // 2 preds: ^bb0, ^bb2
  %1 = tensor.empty() : tensor<i1>
  %2 = linalg.generic #attrs
    ins(%0, %farg1 : tensor<i32>, tensor<i32>)
    outs(%1 : tensor<i1>) {
    ^bb0(%arg0: i32, %arg1: i32, %arg2: i1):
      %8 = arith.cmpi slt, %arg0, %arg1 : i32
      linalg.yield %8 : i1
  } -> tensor<i1>
  %3 = tensor.extract %2[] : tensor<i1>
  cf.cond_br %3, ^bb2(%0 : tensor<i32>), ^bb3(%0 : tensor<i32>)

^bb2(%4: tensor<i32>):  // pred: ^bb1
  %5 = tensor.empty() : tensor<i32>
  %6 = linalg.generic #attrs
    ins(%4, %4 : tensor<i32>, tensor<i32>)
    outs(%5 : tensor<i32>) {
    ^bb0(%arg0: i32, %arg1: i32, %arg2: i32):
      %8 = arith.addi %arg0, %arg1 : i32
      linalg.yield %8 : i32
  } -> tensor<i32>
  cf.br ^bb1(%6 : tensor<i32>)

^bb3(%7: tensor<i32>):  // pred: ^bb1
  return %7 : tensor<i32>
}

// Test aggresively detensoring all detensorable ops.
//
// DET-ALL-LABEL: func @main
// DET-ALL-SAME:    (%{{.*}}: tensor<i32>, %{{.*}}: tensor<i32>)
// DET-ALL:         tensor.extract {{.*}}
// DET-ALL:         cf.br ^[[bb1:.*]](%{{.*}} : i32)
// DET-ALL:       ^[[bb1]](%{{.*}}: i32)
// DET-ALL:         arith.cmpi slt, {{.*}}
// DET-ALL:         cf.cond_br {{.*}}, ^[[bb2:.*]], ^[[bb3:.*]]
// DET-ALL:       ^[[bb2]]
// DET-ALL:         arith.addi {{.*}}
// DET-ALL:         cf.br ^[[bb1]](%{{.*}} : i32)
// DET-ALL:       ^[[bb3]]:
// DET-ALL:         tensor.from_elements {{.*}}
// DET-ALL:         return %{{.*}} : tensor<i32>

// Test detensoring only ops involed in control-flow.
//
// DET-CF-LABEL: func @main
// DET-CF-SAME:    (%{{.*}}: tensor<i32>, %{{.*}}: tensor<i32>)
// DET-CF:         tensor.extract {{.*}}
// DET-CF:         cf.br ^[[bb1:.*]](%{{.*}} : i32)
// DET-CF:       ^[[bb1]](%{{.*}}: i32)
// DET-CF:         arith.cmpi slt, {{.*}}
// DET-CF:         cf.cond_br {{.*}}, ^[[bb2:.*]], ^[[bb3:.*]]
// DET-CF:       ^[[bb2]]:
// DET-CF:         arith.addi {{.*}}
// DET-CF:         cf.br ^[[bb1]](%{{.*}} : i32)
// DET-CF:       ^[[bb3]]:
// DET-CF:         tensor.from_elements %{{.*}} : tensor<i32>
// DET-CF:         return %{{.*}} : tensor<i32>
