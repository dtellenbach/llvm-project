; RUN: llc -mtriple=amdgcn -mcpu=fiji -mattr=-flat-for-global -verify-machineinstrs < %s | FileCheck -check-prefix=GCN -check-prefix=VI %s
; RUN: llc -mtriple=amdgcn -mcpu=gfx1100 -mattr=-flat-for-global,+real-true16 -verify-machineinstrs < %s | FileCheck -check-prefix=GFX11-TRUE16 %s
; RUN: llc -mtriple=amdgcn -mcpu=gfx1100 -mattr=-flat-for-global,-real-true16 -verify-machineinstrs < %s | FileCheck -check-prefix=GFX11-FAKE16 %s

declare half @llvm.amdgcn.rsq.f16(half %a)

; GCN-LABEL: {{^}}rsq_f16
; GCN: buffer_load_ushort v[[A_F16:[0-9]+]]
; VI:  v_rsq_f16_e32 v[[R_F16:[0-9]+]], v[[A_F16]]
; GFX11-TRUE16:  v_rsq_f16_e32 v[[A_F16:[0-9]+]].l, v[[A_F16]].l
; GFX11-FAKE16:  v_rsq_f16_e32 v[[A_F16:[0-9]+]], v[[A_F16]]
; GCN: buffer_store_short v[[R_F16]]
; GCN: s_endpgm
define amdgpu_kernel void @rsq_f16(
    ptr addrspace(1) %r,
    ptr addrspace(1) %a) {
entry:
  %a.val = load half, ptr addrspace(1) %a
  %r.val = call half @llvm.amdgcn.rsq.f16(half %a.val)
  store half %r.val, ptr addrspace(1) %r
  ret void
}
