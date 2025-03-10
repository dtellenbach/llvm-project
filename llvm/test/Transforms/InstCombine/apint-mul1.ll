; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=instcombine -S | FileCheck %s

; This test makes sure that mul instructions are properly eliminated.
; This test is for Integer BitWidth < 64 && BitWidth % 2 != 0.

define i17 @test1(i17 %X) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    [[Y:%.*]] = shl i17 [[X:%.*]], 10
; CHECK-NEXT:    ret i17 [[Y]]
;
  %Y = mul i17 %X, 1024
  ret i17 %Y
}

define <2 x i17> @test2(<2 x i17> %X) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[Y:%.*]] = shl <2 x i17> [[X:%.*]], splat (i17 10)
; CHECK-NEXT:    ret <2 x i17> [[Y]]
;
  %Y = mul <2 x i17> %X, <i17 1024, i17 1024>
  ret <2 x i17> %Y
}

define <2 x i17> @test3(<2 x i17> %X) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[Y:%.*]] = shl <2 x i17> [[X:%.*]], <i17 10, i17 8>
; CHECK-NEXT:    ret <2 x i17> [[Y]]
;
  %Y = mul <2 x i17> %X, <i17 1024, i17 256>
  ret <2 x i17> %Y
}
