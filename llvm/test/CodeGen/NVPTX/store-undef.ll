; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN: llc < %s -march=nvptx64 | FileCheck %s
; RUN: %if ptxas %{ llc < %s -march=nvptx64 | %ptxas-verify %}

target triple = "nvptx64-nvidia-cuda"

%struct.T = type { i64, <2 x i32>, <4 x i32> }

declare void @test_call(%struct.T)

define void @test_store_param_undef() {
; CHECK-LABEL: test_store_param_undef(
; CHECK:       {
; CHECK-EMPTY:
; CHECK-EMPTY:
; CHECK-NEXT:  // %bb.0:
; CHECK-NEXT:    { // callseq 0, 0
; CHECK-NEXT:    .param .align 16 .b8 param0[32];
; CHECK-NEXT:    call.uni
; CHECK-NEXT:    test_call,
; CHECK-NEXT:    (
; CHECK-NEXT:    param0
; CHECK-NEXT:    );
; CHECK-NEXT:    } // callseq 0
; CHECK-NEXT:    ret;
  call void @test_call(%struct.T undef)
  ret void
}

define void @test_store_param_def(i64 %param0, i32 %param1) {
; CHECK-LABEL: test_store_param_def(
; CHECK:       {
; CHECK-NEXT:    .reg .b32 %r<6>;
; CHECK-NEXT:    .reg .b64 %rd<2>;
; CHECK-EMPTY:
; CHECK-NEXT:  // %bb.0:
; CHECK-NEXT:    ld.param.u64 %rd1, [test_store_param_def_param_0];
; CHECK-NEXT:    ld.param.u32 %r1, [test_store_param_def_param_1];
; CHECK-NEXT:    { // callseq 1, 0
; CHECK-NEXT:    .param .align 16 .b8 param0[32];
; CHECK-NEXT:    st.param.b64 [param0+0], %rd1;
; CHECK-NEXT:    st.param.v2.b32 [param0+8], {%r2, %r1};
; CHECK-NEXT:    st.param.v4.b32 [param0+16], {%r3, %r1, %r4, %r5};
; CHECK-NEXT:    call.uni
; CHECK-NEXT:    test_call,
; CHECK-NEXT:    (
; CHECK-NEXT:    param0
; CHECK-NEXT:    );
; CHECK-NEXT:    } // callseq 1
; CHECK-NEXT:    ret;
  %V2 = insertelement <2 x i32> undef, i32 %param1, i32 1
  %V4 = insertelement <4 x i32> undef, i32 %param1, i32 1
  %S0 = insertvalue %struct.T undef, i64 %param0, 0
  %S1 = insertvalue %struct.T %S0, <2 x i32> %V2, 1
  %S2 = insertvalue %struct.T %S1, <4 x i32> %V4, 2
  call void @test_call(%struct.T %S2)
  ret void
}

define void @test_store_undef(ptr %out) {
; CHECK-LABEL: test_store_undef(
; CHECK:       {
; CHECK-EMPTY:
; CHECK-EMPTY:
; CHECK-NEXT:  // %bb.0:
; CHECK-NEXT:    ret;
  store %struct.T undef, ptr %out
  ret void
}

define void @test_store_def(i64 %param0, i32 %param1, ptr %out) {
; CHECK-LABEL: test_store_def(
; CHECK:       {
; CHECK-NEXT:    .reg .b32 %r<6>;
; CHECK-NEXT:    .reg .b64 %rd<3>;
; CHECK-EMPTY:
; CHECK-NEXT:  // %bb.0:
; CHECK-NEXT:    ld.param.u64 %rd1, [test_store_def_param_0];
; CHECK-NEXT:    ld.param.u32 %r1, [test_store_def_param_1];
; CHECK-NEXT:    ld.param.u64 %rd2, [test_store_def_param_2];
; CHECK-NEXT:    st.v4.u32 [%rd2+16], {%r2, %r1, %r3, %r4};
; CHECK-NEXT:    st.v2.u32 [%rd2+8], {%r5, %r1};
; CHECK-NEXT:    st.u64 [%rd2], %rd1;
; CHECK-NEXT:    ret;
  %V2 = insertelement <2 x i32> undef, i32 %param1, i32 1
  %V4 = insertelement <4 x i32> undef, i32 %param1, i32 1
  %S0 = insertvalue %struct.T undef, i64 %param0, 0
  %S1 = insertvalue %struct.T %S0, <2 x i32> %V2, 1
  %S2 = insertvalue %struct.T %S1, <4 x i32> %V4, 2
  store %struct.T %S2, ptr %out
  ret void
}
