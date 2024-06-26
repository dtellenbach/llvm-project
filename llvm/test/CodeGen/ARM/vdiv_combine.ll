; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN: llc < %s -mtriple=armv7-apple-ios | FileCheck %s

; Test signed conversion.
define arm_aapcs_vfpcc <2 x float> @t1(<2 x i32> %vecinit2.i) nounwind {
; CHECK-LABEL: t1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcvt.f32.s32 d0, d0, #3
; CHECK-NEXT:    bx lr
entry:
  %vcvt.i = sitofp <2 x i32> %vecinit2.i to <2 x float>
  %div.i = fdiv <2 x float> %vcvt.i, <float 8.000000e+00, float 8.000000e+00>
  ret <2 x float> %div.i
}

; Test unsigned conversion.
define arm_aapcs_vfpcc <2 x float> @t2(<2 x i32> %vecinit2.i) nounwind {
; CHECK-LABEL: t2:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcvt.f32.u32 d0, d0, #3
; CHECK-NEXT:    bx lr
entry:
  %vcvt.i = uitofp <2 x i32> %vecinit2.i to <2 x float>
  %div.i = fdiv <2 x float> %vcvt.i, <float 8.000000e+00, float 8.000000e+00>
  ret <2 x float> %div.i
}

; Test which should not fold due to non-power of 2.
define arm_aapcs_vfpcc <2 x float> @t3(<2 x i32> %vecinit2.i) nounwind {
; CHECK-LABEL: t3:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcvt.f32.s32 d2, d0
; CHECK-NEXT:    vldr s2, LCPI2_0
; CHECK-NEXT:    vdiv.f32 s1, s5, s2
; CHECK-NEXT:    vdiv.f32 s0, s4, s2
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 2
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:    .data_region
; CHECK-NEXT:  LCPI2_0:
; CHECK-NEXT:    .long 0x40d9999a @ float 6.80000019
; CHECK-NEXT:    .end_data_region
entry:
  %vcvt.i = sitofp <2 x i32> %vecinit2.i to <2 x float>
  %div.i = fdiv <2 x float> %vcvt.i, <float 0x401B333340000000, float 0x401B333340000000>
  ret <2 x float> %div.i
}

; Test which should not fold due to power of 2 out of range.
define arm_aapcs_vfpcc <2 x float> @t4(<2 x i32> %vecinit2.i) nounwind {
; CHECK-LABEL: t4:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcvt.f32.s32 d16, d0
; CHECK-NEXT:    vmov.i32 d17, #0x2f000000
; CHECK-NEXT:    vmul.f32 d0, d16, d17
; CHECK-NEXT:    bx lr
entry:
  %vcvt.i = sitofp <2 x i32> %vecinit2.i to <2 x float>
  %div.i = fdiv <2 x float> %vcvt.i, <float 0x4200000000000000, float 0x4200000000000000>
  ret <2 x float> %div.i
}

; Test case where const is max power of 2 (i.e., 2^32).
define arm_aapcs_vfpcc <2 x float> @t5(<2 x i32> %vecinit2.i) nounwind {
; CHECK-LABEL: t5:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcvt.f32.s32 d0, d0, #32
; CHECK-NEXT:    bx lr
entry:
  %vcvt.i = sitofp <2 x i32> %vecinit2.i to <2 x float>
  %div.i = fdiv <2 x float> %vcvt.i, <float 0x41F0000000000000, float 0x41F0000000000000>
  ret <2 x float> %div.i
}

; Test quadword.
define arm_aapcs_vfpcc <4 x float> @t6(<4 x i32> %vecinit6.i) nounwind {
; CHECK-LABEL: t6:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcvt.f32.s32 q0, q0, #3
; CHECK-NEXT:    bx lr
entry:
  %vcvt.i = sitofp <4 x i32> %vecinit6.i to <4 x float>
  %div.i = fdiv <4 x float> %vcvt.i, <float 8.000000e+00, float 8.000000e+00, float 8.000000e+00, float 8.000000e+00>
  ret <4 x float> %div.i
}

define arm_aapcs_vfpcc <4 x float> @fix_unsigned_i16_to_float(<4 x i16> %in) {
; CHECK-LABEL: fix_unsigned_i16_to_float:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    vmovl.u16 q8, d0
; CHECK-NEXT:    vcvt.f32.u32 q0, q8, #1
; CHECK-NEXT:    bx lr
  %conv = uitofp <4 x i16> %in to <4 x float>
  %shift = fdiv <4 x float> %conv, <float 2.0, float 2.0, float 2.0, float 2.0>
  ret <4 x float> %shift
}

define arm_aapcs_vfpcc <4 x float> @fix_signed_i16_to_float(<4 x i16> %in) {
; CHECK-LABEL: fix_signed_i16_to_float:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    vmovl.s16 q8, d0
; CHECK-NEXT:    vcvt.f32.s32 q0, q8, #1
; CHECK-NEXT:    bx lr
  %conv = sitofp <4 x i16> %in to <4 x float>
  %shift = fdiv <4 x float> %conv, <float 2.0, float 2.0, float 2.0, float 2.0>
  ret <4 x float> %shift
}

define arm_aapcs_vfpcc <2 x float> @fix_i64_to_float(<2 x i64> %in) {
; CHECK-LABEL: fix_i64_to_float:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    push {lr}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vorr q4, q0, q0
; CHECK-NEXT:    vmov r0, r1, d9
; CHECK-NEXT:    bl ___floatundisf
; CHECK-NEXT:    vmov r2, r1, d8
; CHECK-NEXT:    vmov s19, r0
; CHECK-NEXT:    vmov.i32 d8, #0x3f000000
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    bl ___floatundisf
; CHECK-NEXT:    vmov s18, r0
; CHECK-NEXT:    vmul.f32 d0, d9, d8
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {lr}
; CHECK-NEXT:    bx lr
  %conv = uitofp <2 x i64> %in to <2 x float>
  %shift = fdiv <2 x float> %conv, <float 2.0, float 2.0>
  ret <2 x float> %shift
}

define arm_aapcs_vfpcc <2 x double> @fix_i64_to_double(<2 x i64> %in) {
; CHECK-LABEL: fix_i64_to_double:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    push {lr}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vorr q4, q0, q0
; CHECK-NEXT:    vmov r0, r1, d9
; CHECK-NEXT:    bl ___floatundidf
; CHECK-NEXT:    vmov r2, r3, d8
; CHECK-NEXT:    vmov d9, r0, r1
; CHECK-NEXT:    vmov.f64 d8, #5.000000e-01
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    mov r1, r3
; CHECK-NEXT:    bl ___floatundidf
; CHECK-NEXT:    vmov d16, r0, r1
; CHECK-NEXT:    vmul.f64 d1, d9, d8
; CHECK-NEXT:    vmul.f64 d0, d16, d8
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {lr}
; CHECK-NEXT:    bx lr
  %conv = uitofp <2 x i64> %in to <2 x double>
  %shift = fdiv <2 x double> %conv, <double 2.0, double 2.0>
  ret <2 x double> %shift
}

; Don't combine with 8 lanes.  Just make sure things don't crash.
define arm_aapcs_vfpcc <8 x float> @test7(<8 x i32> %in) nounwind {
; CHECK-LABEL: test7:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcvt.f32.s32 q0, q0, #3
; CHECK-NEXT:    vcvt.f32.s32 q1, q1, #3
; CHECK-NEXT:    bx lr
entry:
  %vcvt.i = sitofp <8 x i32> %in to <8 x float>
  %div.i = fdiv <8 x float> %vcvt.i, <float 8.0, float 8.0, float 8.0, float 8.0, float 8.0, float 8.0, float 8.0, float 8.0>
  ret <8 x float> %div.i
}

; Can combine splat with an undef.
define arm_aapcs_vfpcc <4 x float> @test8(<4 x i32> %in) {
; CHECK-LABEL: test8:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    vcvt.f32.s32 q0, q0, #1
; CHECK-NEXT:    bx lr
  %vcvt.i = sitofp <4 x i32> %in to <4 x float>
  %div.i = fdiv <4 x float> %vcvt.i, <float 2.0, float 2.0, float 2.0, float undef>
  ret <4 x float> %div.i
}

define arm_aapcs_vfpcc <3 x float> @test_illegal_int_to_fp(<3 x i32> %in) {
; CHECK-LABEL: test_illegal_int_to_fp:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    vcvt.f32.s32 q0, q0, #2
; CHECK-NEXT:    bx lr
  %conv = sitofp <3 x i32> %in to <3 x float>
  %res = fdiv <3 x float> %conv, <float 4.0, float 4.0, float 4.0>
  ret <3 x float> %res
}


define arm_aapcs_vfpcc <2 x float> @t1_mul(<2 x i32> %vecinit2.i) local_unnamed_addr #0 {
; CHECK-LABEL: t1_mul:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcvt.f32.s32 d0, d0, #3
; CHECK-NEXT:    bx lr
entry:
  %vcvt.i = sitofp <2 x i32> %vecinit2.i to <2 x float>
  %div.i = fmul <2 x float> %vcvt.i, <float 1.250000e-01, float 1.250000e-01>
  ret <2 x float> %div.i
}

define arm_aapcs_vfpcc <2 x float> @t2_mul(<2 x i32> %vecinit2.i) local_unnamed_addr #0 {
; CHECK-LABEL: t2_mul:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcvt.f32.u32 d0, d0, #3
; CHECK-NEXT:    bx lr
entry:
  %vcvt.i = uitofp <2 x i32> %vecinit2.i to <2 x float>
  %div.i = fmul <2 x float> %vcvt.i, <float 1.250000e-01, float 1.250000e-01>
  ret <2 x float> %div.i
}

define arm_aapcs_vfpcc <2 x float> @t4_mul(<2 x i32> %vecinit2.i) local_unnamed_addr #0 {
; CHECK-LABEL: t4_mul:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcvt.f32.s32 d16, d0
; CHECK-NEXT:    vmov.i32 d17, #0x2f000000
; CHECK-NEXT:    vmul.f32 d0, d16, d17
; CHECK-NEXT:    bx lr
entry:
  %vcvt.i = sitofp <2 x i32> %vecinit2.i to <2 x float>
  %div.i = fmul <2 x float> %vcvt.i, <float 0x3DE0000000000000, float 0x3DE0000000000000>
  ret <2 x float> %div.i
}

define arm_aapcs_vfpcc <2 x float> @t5_mul(<2 x i32> %vecinit2.i) local_unnamed_addr #0 {
; CHECK-LABEL: t5_mul:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcvt.f32.s32 d0, d0, #32
; CHECK-NEXT:    bx lr
entry:
  %vcvt.i = sitofp <2 x i32> %vecinit2.i to <2 x float>
  %div.i = fmul <2 x float> %vcvt.i, <float 0x3DF0000000000000, float 0x3DF0000000000000>
  ret <2 x float> %div.i
}

define arm_aapcs_vfpcc <4 x float> @t6_mul(<4 x i32> %vecinit6.i) local_unnamed_addr #0 {
; CHECK-LABEL: t6_mul:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcvt.f32.s32 q0, q0, #3
; CHECK-NEXT:    bx lr
entry:
  %vcvt.i = sitofp <4 x i32> %vecinit6.i to <4 x float>
  %div.i = fmul <4 x float> %vcvt.i, <float 1.250000e-01, float 1.250000e-01, float 1.250000e-01, float 1.250000e-01>
  ret <4 x float> %div.i
}

define arm_aapcs_vfpcc <4 x float> @fix_unsigned_i16_to_float_mul(<4 x i16> %in) local_unnamed_addr #0 {
; CHECK-LABEL: fix_unsigned_i16_to_float_mul:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    vmovl.u16 q8, d0
; CHECK-NEXT:    vcvt.f32.u32 q0, q8, #1
; CHECK-NEXT:    bx lr
  %conv = uitofp <4 x i16> %in to <4 x float>
  %shift = fmul <4 x float> %conv, <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>
  ret <4 x float> %shift
}

define arm_aapcs_vfpcc <4 x float> @fix_signed_i16_to_float_mul(<4 x i16> %in) local_unnamed_addr #0 {
; CHECK-LABEL: fix_signed_i16_to_float_mul:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    vmovl.s16 q8, d0
; CHECK-NEXT:    vcvt.f32.s32 q0, q8, #1
; CHECK-NEXT:    bx lr
  %conv = sitofp <4 x i16> %in to <4 x float>
  %shift = fmul <4 x float> %conv, <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>
  ret <4 x float> %shift
}

define arm_aapcs_vfpcc <2 x float> @fix_i64_to_float_mul(<2 x i64> %in) local_unnamed_addr #0 {
; CHECK-LABEL: fix_i64_to_float_mul:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    push {lr}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vorr q4, q0, q0
; CHECK-NEXT:    vmov r0, r1, d9
; CHECK-NEXT:    bl ___floatundisf
; CHECK-NEXT:    vmov r2, r1, d8
; CHECK-NEXT:    vmov s19, r0
; CHECK-NEXT:    vmov.i32 d8, #0x3f000000
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    bl ___floatundisf
; CHECK-NEXT:    vmov s18, r0
; CHECK-NEXT:    vmul.f32 d0, d9, d8
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {lr}
; CHECK-NEXT:    bx lr
  %conv = uitofp <2 x i64> %in to <2 x float>
  %shift = fmul <2 x float> %conv, <float 5.000000e-01, float 5.000000e-01>
  ret <2 x float> %shift
}

define arm_aapcs_vfpcc <2 x double> @fix_i64_to_double_mul(<2 x i64> %in) local_unnamed_addr #0 {
; CHECK-LABEL: fix_i64_to_double_mul:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    push {lr}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vorr q4, q0, q0
; CHECK-NEXT:    vmov r0, r1, d9
; CHECK-NEXT:    bl ___floatundidf
; CHECK-NEXT:    vmov r2, r3, d8
; CHECK-NEXT:    vmov d9, r0, r1
; CHECK-NEXT:    vmov.f64 d8, #5.000000e-01
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    mov r1, r3
; CHECK-NEXT:    bl ___floatundidf
; CHECK-NEXT:    vmov d16, r0, r1
; CHECK-NEXT:    vmul.f64 d1, d9, d8
; CHECK-NEXT:    vmul.f64 d0, d16, d8
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {lr}
; CHECK-NEXT:    bx lr
  %conv = uitofp <2 x i64> %in to <2 x double>
  %shift = fmul <2 x double> %conv, <double 5.000000e-01, double 5.000000e-01>
  ret <2 x double> %shift
}

define arm_aapcs_vfpcc <8 x float> @test7_mul(<8 x i32> %in) local_unnamed_addr #0 {
; CHECK-LABEL: test7_mul:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcvt.f32.s32 q0, q0, #3
; CHECK-NEXT:    vcvt.f32.s32 q1, q1, #3
; CHECK-NEXT:    bx lr
entry:
  %vcvt.i = sitofp <8 x i32> %in to <8 x float>
  %div.i = fmul <8 x float> %vcvt.i, <float 1.250000e-01, float 1.250000e-01, float 1.250000e-01, float 1.250000e-01, float 1.250000e-01, float 1.250000e-01, float 1.250000e-01, float 1.250000e-01>
  ret <8 x float> %div.i
}

define arm_aapcs_vfpcc <3 x float> @test_illegal_int_to_fp_mul(<3 x i32> %in) local_unnamed_addr #0 {
; CHECK-LABEL: test_illegal_int_to_fp_mul:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    vcvt.f32.s32 q0, q0, #2
; CHECK-NEXT:    bx lr
  %conv = sitofp <3 x i32> %in to <3 x float>
  %res = fmul <3 x float> %conv, <float 2.500000e-01, float 2.500000e-01, float 2.500000e-01>
  ret <3 x float> %res
}
