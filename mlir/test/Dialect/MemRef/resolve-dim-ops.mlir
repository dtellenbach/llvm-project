// RUN: mlir-opt --resolve-ranked-shaped-type-result-dims --split-input-file %s | FileCheck %s

// CHECK-LABEL: func @dim_out_of_bounds(
//  CHECK-NEXT:   arith.constant
//  CHECK-NEXT:   memref.dim
//  CHECK-NEXT:   return
func.func @dim_out_of_bounds(%m : memref<7x8xf32>) -> index {
  %idx = arith.constant 7 : index
  %0 = memref.dim %m, %idx : memref<7x8xf32>
  return %0 : index
}

// -----

// CHECK-LABEL: func @dim_out_of_bounds_2(
//  CHECK-NEXT:   arith.constant
//  CHECK-NEXT:   arith.constant
//  CHECK-NEXT:   bufferization.alloc_tensor
//  CHECK-NEXT:   tensor.dim
//  CHECK-NEXT:   return
func.func @dim_out_of_bounds_2(%idx1 : index, %idx2 : index) -> index {
  %idx = arith.constant 7 : index
  %sz = arith.constant 5 : index
  %alloc = bufferization.alloc_tensor(%sz, %sz) : tensor<?x?xf32>
  %0 = tensor.dim %alloc, %idx : tensor<?x?xf32>
  return %0 : index
}

// -----

// CHECK-LABEL:   func.func @dynamic_dim_of_transpose_op(
//  CHECK-SAME:                                   %[[arg:.*]]: tensor<1x2x?x8xi8>) -> index {
//  CHECK-NEXT:           %[[c2:.*]] = arith.constant 2
//  CHECK-NEXT:           tensor.dim %[[arg]], %[[c2]]
//  CHECK-NEXT:           return
func.func @dynamic_dim_of_transpose_op(%arg0: tensor<1x2x?x8xi8>) -> index {
  %1 = tosa.transpose %arg0 { perms = array<i32: 0, 3, 1, 2> }: (tensor<1x2x?x8xi8>) -> tensor<1x8x2x?xi8>
  %c3 = arith.constant 3 : index
  %dim = tensor.dim %1, %c3 : tensor<1x8x2x?xi8>
  return %dim : index
}

// -----

// CHECK-LABEL:   func.func @static_dim_of_transpose_op(
//  CHECK:           arith.constant 100 : index
//  CHECK:           return
func.func @static_dim_of_transpose_op(%arg0: tensor<1x100x?x8xi8>) -> index {
  %1 = tosa.transpose %arg0 { perms = array<i32: 0, 3, 1, 2> }: (tensor<1x100x?x8xi8>) -> tensor<1x8x100x?xi8>
  %c2 = arith.constant 2 : index
  %dim = tensor.dim %1, %c2 : tensor<1x8x100x?xi8>
  return %dim : index
}

// -----

// Test case: Folding of memref.dim(memref.expand_shape)
// CHECK-LABEL: func @dim_of_memref_expand_shape(
//  CHECK-SAME:     %[[MEM:[0-9a-z]+]]: memref<?x8xi32>
//  CHECK-NEXT:   %[[IDX:.*]] = arith.constant 0
//  CHECK-NEXT:   %[[DIM:.*]] = memref.dim %[[MEM]], %[[IDX]] : memref<?x8xi32>
//       CHECK:   return %[[DIM]] : index
func.func @dim_of_memref_expand_shape(%arg0: memref<?x8xi32>)
    -> index {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %s = memref.dim %arg0, %c0 : memref<?x8xi32>
  %0 = memref.expand_shape %arg0 [[0, 1], [2, 3]] output_shape [1, %s, 2, 4]: memref<?x8xi32> into memref<1x?x2x4xi32>
  %1 = memref.dim %0, %c1 : memref<1x?x2x4xi32>
  return %1 : index
}

// -----

// CHECK-LABEL: @iter_to_init_arg_loop_like
//  CHECK-SAME:   (%[[ARG0:.*]]: tensor<?x?xf32>, %[[ARG1:.*]]: tensor<?x?xf32>) -> tensor<?x?xf32> {
//       CHECK:    %[[RESULT:.*]] = scf.forall
//  CHECK-SAME:                       shared_outs(%[[OUTS:.*]] = %[[ARG1]]) -> (tensor<?x?xf32>) {
//  CHECK-NEXT:       %{{.*}} = tensor.dim %[[ARG1]], %{{.*}} : tensor<?x?xf32>
func.func @iter_to_init_arg_loop_like(
  %arg0 : tensor<?x?xf32>, %arg1: tensor<?x?xf32>) -> tensor<?x?xf32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %dim0 = tensor.dim %arg0, %c0 : tensor<?x?xf32>

  %result = scf.forall (%i) = (%c0) to (%dim0)
      step (%c1) shared_outs(%o = %arg1) -> (tensor<?x?xf32>) {

    %dim1 = tensor.dim %o, %c1 : tensor<?x?xf32>
    %slice = tensor.extract_slice %arg1[%i, 0] [1, %dim1] [1, 1]
      : tensor<?x?xf32> to tensor<1x?xf32>

    scf.forall.in_parallel {
      tensor.parallel_insert_slice %slice into %o[%i, 0] [1, %dim1] [1, 1]
        : tensor<1x?xf32> into tensor<?x?xf32>
    }
  }
  return %result : tensor<?x?xf32>
}
