; RUN: opt < %s -passes=loop-vectorize -mtriple x86_64 -debug -disable-output 2>&1 | FileCheck %s
; REQUIRES: asserts

; Check that cost model is not executed twice for VF=2 when vectorization is
; forced for a particular loop.

; CHECK: Cost of {{.*}} for VF 2: WIDEN {{.*}} = load
; CHECK: Cost of {{.*}} for VF 2: WIDEN store
; CHECK-NOT: Cost of {{.*}} for VF 2: WIDEN {{.*}} = load
; CHECK-NOT: Cost of {{.*}} for VF 2: WIDEN store
; CHECK: Cost for VF 2: 5 (Estimated cost per lane: 2.

define i32 @foo(ptr %A, i32 %n) {
entry:
  %cmp3.i = icmp eq i32 %n, 0
  br i1 %cmp3.i, label %exit, label %for.body.i

for.body.i:
  %iv = phi i32 [ %add.i, %for.body.i ], [ 0, %entry ]
  %ld_addr = getelementptr inbounds i32, ptr %A, i32 %iv
  %0 = load i32, ptr %ld_addr, align 4
  %val = add i32 %0, 1
  store i32 %val, ptr %ld_addr, align 4
  %add.i = add nsw i32 %iv, 1
  %cmp.i = icmp eq i32 %add.i, %n
  br i1 %cmp.i, label %exit, label %for.body.i, !llvm.loop !0

exit:
  %__init.addr.0.lcssa.i = phi i32 [ 0, %entry ], [ %add.i, %for.body.i ]
  ret i32 %__init.addr.0.lcssa.i
}

!0 = !{!0, !1}
!1 = !{!"llvm.loop.vectorize.enable", i1 true}
