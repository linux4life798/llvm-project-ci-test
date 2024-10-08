; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin      -mcpu=core2     | FileCheck %s -check-prefix=DARWIN
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mcpu=core2     | FileCheck %s -check-prefix=LINUX
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mcpu=skylake   | FileCheck %s -check-prefix=LINUX-SKL
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mcpu=skx       | FileCheck %s -check-prefix=LINUX-SKX
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mcpu=knl       | FileCheck %s -check-prefix=LINUX-KNL
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mattr=avx512bw | FileCheck %s -check-prefix=LINUX-AVX512BW

declare void @llvm.memcpy.p0.p0.i64(ptr nocapture, ptr nocapture, i64, i1) nounwind
declare void @llvm.memcpy.p256.p256.i64(ptr addrspace(256) nocapture, ptr addrspace(256) nocapture, i64, i1) nounwind


; Variable memcpy's should lower to calls.
define ptr @test1(ptr %a, ptr %b, i64 %n) nounwind {
; DARWIN-LABEL: test1:
; DARWIN:       ## %bb.0: ## %entry
; DARWIN-NEXT:    jmp _memcpy ## TAILCALL
;
; LINUX-LABEL: test1:
; LINUX:       # %bb.0: # %entry
; LINUX-NEXT:    jmp memcpy@PLT # TAILCALL
;
; LINUX-SKL-LABEL: test1:
; LINUX-SKL:       # %bb.0: # %entry
; LINUX-SKL-NEXT:    jmp memcpy@PLT # TAILCALL
;
; LINUX-SKX-LABEL: test1:
; LINUX-SKX:       # %bb.0: # %entry
; LINUX-SKX-NEXT:    jmp memcpy@PLT # TAILCALL
;
; LINUX-KNL-LABEL: test1:
; LINUX-KNL:       # %bb.0: # %entry
; LINUX-KNL-NEXT:    jmp memcpy@PLT # TAILCALL
;
; LINUX-AVX512BW-LABEL: test1:
; LINUX-AVX512BW:       # %bb.0: # %entry
; LINUX-AVX512BW-NEXT:    jmp memcpy@PLT # TAILCALL
entry:
	tail call void @llvm.memcpy.p0.p0.i64(ptr %a, ptr %b, i64 %n, i1 0 )
	ret ptr %a
}

; Variable memcpy's should lower to calls.
define ptr @test2(ptr %a, ptr %b, i64 %n) nounwind {
; DARWIN-LABEL: test2:
; DARWIN:       ## %bb.0: ## %entry
; DARWIN-NEXT:    jmp _memcpy ## TAILCALL
;
; LINUX-LABEL: test2:
; LINUX:       # %bb.0: # %entry
; LINUX-NEXT:    jmp memcpy@PLT # TAILCALL
;
; LINUX-SKL-LABEL: test2:
; LINUX-SKL:       # %bb.0: # %entry
; LINUX-SKL-NEXT:    jmp memcpy@PLT # TAILCALL
;
; LINUX-SKX-LABEL: test2:
; LINUX-SKX:       # %bb.0: # %entry
; LINUX-SKX-NEXT:    jmp memcpy@PLT # TAILCALL
;
; LINUX-KNL-LABEL: test2:
; LINUX-KNL:       # %bb.0: # %entry
; LINUX-KNL-NEXT:    jmp memcpy@PLT # TAILCALL
;
; LINUX-AVX512BW-LABEL: test2:
; LINUX-AVX512BW:       # %bb.0: # %entry
; LINUX-AVX512BW-NEXT:    jmp memcpy@PLT # TAILCALL
entry:
	tail call void @llvm.memcpy.p0.p0.i64(ptr align 8 %a, ptr align 8 %b, i64 %n, i1 0 )
	ret ptr %a
}

; Large constant memcpy's should lower to a call when optimizing for size.
; PR6623

; On the other hand, Darwin's definition of -Os is optimizing for size without
; hurting performance so it should just ignore optsize when expanding memcpy.
; rdar://8821501
define void @test3(ptr nocapture %A, ptr nocapture %B) nounwind optsize noredzone {
; DARWIN-LABEL: test3:
; DARWIN:       ## %bb.0: ## %entry
; DARWIN-NEXT:    movq 56(%rsi), %rax
; DARWIN-NEXT:    movq %rax, 56(%rdi)
; DARWIN-NEXT:    movq 48(%rsi), %rax
; DARWIN-NEXT:    movq %rax, 48(%rdi)
; DARWIN-NEXT:    movq 40(%rsi), %rax
; DARWIN-NEXT:    movq %rax, 40(%rdi)
; DARWIN-NEXT:    movq 32(%rsi), %rax
; DARWIN-NEXT:    movq %rax, 32(%rdi)
; DARWIN-NEXT:    movq 24(%rsi), %rax
; DARWIN-NEXT:    movq %rax, 24(%rdi)
; DARWIN-NEXT:    movq 16(%rsi), %rax
; DARWIN-NEXT:    movq %rax, 16(%rdi)
; DARWIN-NEXT:    movq (%rsi), %rax
; DARWIN-NEXT:    movq 8(%rsi), %rcx
; DARWIN-NEXT:    movq %rcx, 8(%rdi)
; DARWIN-NEXT:    movq %rax, (%rdi)
; DARWIN-NEXT:    retq
;
; LINUX-LABEL: test3:
; LINUX:       # %bb.0: # %entry
; LINUX-NEXT:    movl $64, %edx
; LINUX-NEXT:    jmp memcpy@PLT # TAILCALL
;
; LINUX-SKL-LABEL: test3:
; LINUX-SKL:       # %bb.0: # %entry
; LINUX-SKL-NEXT:    vmovups (%rsi), %ymm0
; LINUX-SKL-NEXT:    vmovups 32(%rsi), %ymm1
; LINUX-SKL-NEXT:    vmovups %ymm1, 32(%rdi)
; LINUX-SKL-NEXT:    vmovups %ymm0, (%rdi)
; LINUX-SKL-NEXT:    vzeroupper
; LINUX-SKL-NEXT:    retq
;
; LINUX-SKX-LABEL: test3:
; LINUX-SKX:       # %bb.0: # %entry
; LINUX-SKX-NEXT:    vmovups (%rsi), %ymm0
; LINUX-SKX-NEXT:    vmovups 32(%rsi), %ymm1
; LINUX-SKX-NEXT:    vmovups %ymm1, 32(%rdi)
; LINUX-SKX-NEXT:    vmovups %ymm0, (%rdi)
; LINUX-SKX-NEXT:    vzeroupper
; LINUX-SKX-NEXT:    retq
;
; LINUX-KNL-LABEL: test3:
; LINUX-KNL:       # %bb.0: # %entry
; LINUX-KNL-NEXT:    vmovups (%rsi), %zmm0
; LINUX-KNL-NEXT:    vmovups %zmm0, (%rdi)
; LINUX-KNL-NEXT:    retq
;
; LINUX-AVX512BW-LABEL: test3:
; LINUX-AVX512BW:       # %bb.0: # %entry
; LINUX-AVX512BW-NEXT:    vmovups (%rsi), %zmm0
; LINUX-AVX512BW-NEXT:    vmovups %zmm0, (%rdi)
; LINUX-AVX512BW-NEXT:    vzeroupper
; LINUX-AVX512BW-NEXT:    retq
entry:
  tail call void @llvm.memcpy.p0.p0.i64(ptr %A, ptr %B, i64 64, i1 false)
  ret void
}

define void @test3_pgso(ptr nocapture %A, ptr nocapture %B) nounwind noredzone !prof !14 {
; DARWIN-LABEL: test3_pgso:
; DARWIN:       ## %bb.0: ## %entry
; DARWIN-NEXT:    movq 56(%rsi), %rax
; DARWIN-NEXT:    movq %rax, 56(%rdi)
; DARWIN-NEXT:    movq 48(%rsi), %rax
; DARWIN-NEXT:    movq %rax, 48(%rdi)
; DARWIN-NEXT:    movq 40(%rsi), %rax
; DARWIN-NEXT:    movq %rax, 40(%rdi)
; DARWIN-NEXT:    movq 32(%rsi), %rax
; DARWIN-NEXT:    movq %rax, 32(%rdi)
; DARWIN-NEXT:    movq 24(%rsi), %rax
; DARWIN-NEXT:    movq %rax, 24(%rdi)
; DARWIN-NEXT:    movq 16(%rsi), %rax
; DARWIN-NEXT:    movq %rax, 16(%rdi)
; DARWIN-NEXT:    movq (%rsi), %rax
; DARWIN-NEXT:    movq 8(%rsi), %rcx
; DARWIN-NEXT:    movq %rcx, 8(%rdi)
; DARWIN-NEXT:    movq %rax, (%rdi)
; DARWIN-NEXT:    retq
;
; LINUX-LABEL: test3_pgso:
; LINUX:       # %bb.0: # %entry
; LINUX-NEXT:    movl $64, %edx
; LINUX-NEXT:    jmp memcpy@PLT # TAILCALL
;
; LINUX-SKL-LABEL: test3_pgso:
; LINUX-SKL:       # %bb.0: # %entry
; LINUX-SKL-NEXT:    vmovups (%rsi), %ymm0
; LINUX-SKL-NEXT:    vmovups 32(%rsi), %ymm1
; LINUX-SKL-NEXT:    vmovups %ymm1, 32(%rdi)
; LINUX-SKL-NEXT:    vmovups %ymm0, (%rdi)
; LINUX-SKL-NEXT:    vzeroupper
; LINUX-SKL-NEXT:    retq
;
; LINUX-SKX-LABEL: test3_pgso:
; LINUX-SKX:       # %bb.0: # %entry
; LINUX-SKX-NEXT:    vmovups (%rsi), %ymm0
; LINUX-SKX-NEXT:    vmovups 32(%rsi), %ymm1
; LINUX-SKX-NEXT:    vmovups %ymm1, 32(%rdi)
; LINUX-SKX-NEXT:    vmovups %ymm0, (%rdi)
; LINUX-SKX-NEXT:    vzeroupper
; LINUX-SKX-NEXT:    retq
;
; LINUX-KNL-LABEL: test3_pgso:
; LINUX-KNL:       # %bb.0: # %entry
; LINUX-KNL-NEXT:    vmovups (%rsi), %zmm0
; LINUX-KNL-NEXT:    vmovups %zmm0, (%rdi)
; LINUX-KNL-NEXT:    retq
;
; LINUX-AVX512BW-LABEL: test3_pgso:
; LINUX-AVX512BW:       # %bb.0: # %entry
; LINUX-AVX512BW-NEXT:    vmovups (%rsi), %zmm0
; LINUX-AVX512BW-NEXT:    vmovups %zmm0, (%rdi)
; LINUX-AVX512BW-NEXT:    vzeroupper
; LINUX-AVX512BW-NEXT:    retq
entry:
  tail call void @llvm.memcpy.p0.p0.i64(ptr %A, ptr %B, i64 64, i1 false)
  ret void
}

define void @test3_minsize(ptr nocapture %A, ptr nocapture %B) nounwind minsize noredzone {
; DARWIN-LABEL: test3_minsize:
; DARWIN:       ## %bb.0:
; DARWIN-NEXT:    pushq $64
; DARWIN-NEXT:    popq %rcx
; DARWIN-NEXT:    rep;movsb (%rsi), %es:(%rdi)
; DARWIN-NEXT:    retq
;
; LINUX-LABEL: test3_minsize:
; LINUX:       # %bb.0:
; LINUX-NEXT:    pushq $64
; LINUX-NEXT:    popq %rcx
; LINUX-NEXT:    rep;movsb (%rsi), %es:(%rdi)
; LINUX-NEXT:    retq
;
; LINUX-SKL-LABEL: test3_minsize:
; LINUX-SKL:       # %bb.0:
; LINUX-SKL-NEXT:    vmovups (%rsi), %ymm0
; LINUX-SKL-NEXT:    vmovups 32(%rsi), %ymm1
; LINUX-SKL-NEXT:    vmovups %ymm1, 32(%rdi)
; LINUX-SKL-NEXT:    vmovups %ymm0, (%rdi)
; LINUX-SKL-NEXT:    vzeroupper
; LINUX-SKL-NEXT:    retq
;
; LINUX-SKX-LABEL: test3_minsize:
; LINUX-SKX:       # %bb.0:
; LINUX-SKX-NEXT:    vmovups (%rsi), %ymm0
; LINUX-SKX-NEXT:    vmovups 32(%rsi), %ymm1
; LINUX-SKX-NEXT:    vmovups %ymm1, 32(%rdi)
; LINUX-SKX-NEXT:    vmovups %ymm0, (%rdi)
; LINUX-SKX-NEXT:    vzeroupper
; LINUX-SKX-NEXT:    retq
;
; LINUX-KNL-LABEL: test3_minsize:
; LINUX-KNL:       # %bb.0:
; LINUX-KNL-NEXT:    vmovups (%rsi), %zmm0
; LINUX-KNL-NEXT:    vmovups %zmm0, (%rdi)
; LINUX-KNL-NEXT:    retq
;
; LINUX-AVX512BW-LABEL: test3_minsize:
; LINUX-AVX512BW:       # %bb.0:
; LINUX-AVX512BW-NEXT:    vmovups (%rsi), %zmm0
; LINUX-AVX512BW-NEXT:    vmovups %zmm0, (%rdi)
; LINUX-AVX512BW-NEXT:    vzeroupper
; LINUX-AVX512BW-NEXT:    retq
  tail call void @llvm.memcpy.p0.p0.i64(ptr %A, ptr %B, i64 64, i1 false)
  ret void
}

define void @test3_minsize_optsize(ptr nocapture %A, ptr nocapture %B) nounwind optsize minsize noredzone {
; DARWIN-LABEL: test3_minsize_optsize:
; DARWIN:       ## %bb.0:
; DARWIN-NEXT:    pushq $64
; DARWIN-NEXT:    popq %rcx
; DARWIN-NEXT:    rep;movsb (%rsi), %es:(%rdi)
; DARWIN-NEXT:    retq
;
; LINUX-LABEL: test3_minsize_optsize:
; LINUX:       # %bb.0:
; LINUX-NEXT:    pushq $64
; LINUX-NEXT:    popq %rcx
; LINUX-NEXT:    rep;movsb (%rsi), %es:(%rdi)
; LINUX-NEXT:    retq
;
; LINUX-SKL-LABEL: test3_minsize_optsize:
; LINUX-SKL:       # %bb.0:
; LINUX-SKL-NEXT:    vmovups (%rsi), %ymm0
; LINUX-SKL-NEXT:    vmovups 32(%rsi), %ymm1
; LINUX-SKL-NEXT:    vmovups %ymm1, 32(%rdi)
; LINUX-SKL-NEXT:    vmovups %ymm0, (%rdi)
; LINUX-SKL-NEXT:    vzeroupper
; LINUX-SKL-NEXT:    retq
;
; LINUX-SKX-LABEL: test3_minsize_optsize:
; LINUX-SKX:       # %bb.0:
; LINUX-SKX-NEXT:    vmovups (%rsi), %ymm0
; LINUX-SKX-NEXT:    vmovups 32(%rsi), %ymm1
; LINUX-SKX-NEXT:    vmovups %ymm1, 32(%rdi)
; LINUX-SKX-NEXT:    vmovups %ymm0, (%rdi)
; LINUX-SKX-NEXT:    vzeroupper
; LINUX-SKX-NEXT:    retq
;
; LINUX-KNL-LABEL: test3_minsize_optsize:
; LINUX-KNL:       # %bb.0:
; LINUX-KNL-NEXT:    vmovups (%rsi), %zmm0
; LINUX-KNL-NEXT:    vmovups %zmm0, (%rdi)
; LINUX-KNL-NEXT:    retq
;
; LINUX-AVX512BW-LABEL: test3_minsize_optsize:
; LINUX-AVX512BW:       # %bb.0:
; LINUX-AVX512BW-NEXT:    vmovups (%rsi), %zmm0
; LINUX-AVX512BW-NEXT:    vmovups %zmm0, (%rdi)
; LINUX-AVX512BW-NEXT:    vzeroupper
; LINUX-AVX512BW-NEXT:    retq
  tail call void @llvm.memcpy.p0.p0.i64(ptr %A, ptr %B, i64 64, i1 false)
  ret void
}

; Large constant memcpy's should be inlined when not optimizing for size.
define void @test4(ptr nocapture %A, ptr nocapture %B) nounwind noredzone {
; DARWIN-LABEL: test4:
; DARWIN:       ## %bb.0: ## %entry
; DARWIN-NEXT:    movq 56(%rsi), %rax
; DARWIN-NEXT:    movq %rax, 56(%rdi)
; DARWIN-NEXT:    movq 48(%rsi), %rax
; DARWIN-NEXT:    movq %rax, 48(%rdi)
; DARWIN-NEXT:    movq 40(%rsi), %rax
; DARWIN-NEXT:    movq %rax, 40(%rdi)
; DARWIN-NEXT:    movq 32(%rsi), %rax
; DARWIN-NEXT:    movq %rax, 32(%rdi)
; DARWIN-NEXT:    movq 24(%rsi), %rax
; DARWIN-NEXT:    movq %rax, 24(%rdi)
; DARWIN-NEXT:    movq 16(%rsi), %rax
; DARWIN-NEXT:    movq %rax, 16(%rdi)
; DARWIN-NEXT:    movq (%rsi), %rax
; DARWIN-NEXT:    movq 8(%rsi), %rcx
; DARWIN-NEXT:    movq %rcx, 8(%rdi)
; DARWIN-NEXT:    movq %rax, (%rdi)
; DARWIN-NEXT:    retq
;
; LINUX-LABEL: test4:
; LINUX:       # %bb.0: # %entry
; LINUX-NEXT:    movq 56(%rsi), %rax
; LINUX-NEXT:    movq %rax, 56(%rdi)
; LINUX-NEXT:    movq 48(%rsi), %rax
; LINUX-NEXT:    movq %rax, 48(%rdi)
; LINUX-NEXT:    movq 40(%rsi), %rax
; LINUX-NEXT:    movq %rax, 40(%rdi)
; LINUX-NEXT:    movq 32(%rsi), %rax
; LINUX-NEXT:    movq %rax, 32(%rdi)
; LINUX-NEXT:    movq 24(%rsi), %rax
; LINUX-NEXT:    movq %rax, 24(%rdi)
; LINUX-NEXT:    movq 16(%rsi), %rax
; LINUX-NEXT:    movq %rax, 16(%rdi)
; LINUX-NEXT:    movq (%rsi), %rax
; LINUX-NEXT:    movq 8(%rsi), %rcx
; LINUX-NEXT:    movq %rcx, 8(%rdi)
; LINUX-NEXT:    movq %rax, (%rdi)
; LINUX-NEXT:    retq
;
; LINUX-SKL-LABEL: test4:
; LINUX-SKL:       # %bb.0: # %entry
; LINUX-SKL-NEXT:    vmovups (%rsi), %ymm0
; LINUX-SKL-NEXT:    vmovups 32(%rsi), %ymm1
; LINUX-SKL-NEXT:    vmovups %ymm1, 32(%rdi)
; LINUX-SKL-NEXT:    vmovups %ymm0, (%rdi)
; LINUX-SKL-NEXT:    vzeroupper
; LINUX-SKL-NEXT:    retq
;
; LINUX-SKX-LABEL: test4:
; LINUX-SKX:       # %bb.0: # %entry
; LINUX-SKX-NEXT:    vmovups (%rsi), %ymm0
; LINUX-SKX-NEXT:    vmovups 32(%rsi), %ymm1
; LINUX-SKX-NEXT:    vmovups %ymm1, 32(%rdi)
; LINUX-SKX-NEXT:    vmovups %ymm0, (%rdi)
; LINUX-SKX-NEXT:    vzeroupper
; LINUX-SKX-NEXT:    retq
;
; LINUX-KNL-LABEL: test4:
; LINUX-KNL:       # %bb.0: # %entry
; LINUX-KNL-NEXT:    vmovups (%rsi), %zmm0
; LINUX-KNL-NEXT:    vmovups %zmm0, (%rdi)
; LINUX-KNL-NEXT:    retq
;
; LINUX-AVX512BW-LABEL: test4:
; LINUX-AVX512BW:       # %bb.0: # %entry
; LINUX-AVX512BW-NEXT:    vmovups (%rsi), %zmm0
; LINUX-AVX512BW-NEXT:    vmovups %zmm0, (%rdi)
; LINUX-AVX512BW-NEXT:    vzeroupper
; LINUX-AVX512BW-NEXT:    retq
entry:
  tail call void @llvm.memcpy.p0.p0.i64(ptr %A, ptr %B, i64 64, i1 false)
  ret void
}


@.str = private unnamed_addr constant [30 x i8] c"\00aaaaaaaaaaaaaaaaaaaaaaaaaaaa\00", align 1

define void @test5(ptr nocapture %C) nounwind uwtable ssp {
; DARWIN-LABEL: test5:
; DARWIN:       ## %bb.0: ## %entry
; DARWIN-NEXT:    movabsq $7016996765293437281, %rax ## imm = 0x6161616161616161
; DARWIN-NEXT:    movq %rax, 8(%rdi)
; DARWIN-NEXT:    movabsq $7016996765293437184, %rax ## imm = 0x6161616161616100
; DARWIN-NEXT:    movq %rax, (%rdi)
; DARWIN-NEXT:    retq
;
; LINUX-LABEL: test5:
; LINUX:       # %bb.0: # %entry
; LINUX-NEXT:    movabsq $7016996765293437281, %rax # imm = 0x6161616161616161
; LINUX-NEXT:    movq %rax, 8(%rdi)
; LINUX-NEXT:    movabsq $7016996765293437184, %rax # imm = 0x6161616161616100
; LINUX-NEXT:    movq %rax, (%rdi)
; LINUX-NEXT:    retq
;
; LINUX-SKL-LABEL: test5:
; LINUX-SKL:       # %bb.0: # %entry
; LINUX-SKL-NEXT:    vmovups .L.str(%rip), %xmm0
; LINUX-SKL-NEXT:    vmovups %xmm0, (%rdi)
; LINUX-SKL-NEXT:    retq
;
; LINUX-SKX-LABEL: test5:
; LINUX-SKX:       # %bb.0: # %entry
; LINUX-SKX-NEXT:    vmovups .L.str(%rip), %xmm0
; LINUX-SKX-NEXT:    vmovups %xmm0, (%rdi)
; LINUX-SKX-NEXT:    retq
;
; LINUX-KNL-LABEL: test5:
; LINUX-KNL:       # %bb.0: # %entry
; LINUX-KNL-NEXT:    vmovups .L.str(%rip), %xmm0
; LINUX-KNL-NEXT:    vmovups %xmm0, (%rdi)
; LINUX-KNL-NEXT:    retq
;
; LINUX-AVX512BW-LABEL: test5:
; LINUX-AVX512BW:       # %bb.0: # %entry
; LINUX-AVX512BW-NEXT:    vmovups .L.str(%rip), %xmm0
; LINUX-AVX512BW-NEXT:    vmovups %xmm0, (%rdi)
; LINUX-AVX512BW-NEXT:    retq
entry:
  tail call void @llvm.memcpy.p0.p0.i64(ptr %C, ptr @.str, i64 16, i1 false)
  ret void
}


; PR14896
@.str2 = private unnamed_addr constant [2 x i8] c"x\00", align 1

define void @test6() nounwind uwtable {
; DARWIN-LABEL: test6:
; DARWIN:       ## %bb.0: ## %entry
; DARWIN-NEXT:    movw $0, 8
; DARWIN-NEXT:    movq $120, 0
; DARWIN-NEXT:    retq
;
; LINUX-LABEL: test6:
; LINUX:       # %bb.0: # %entry
; LINUX-NEXT:    movw $0, 8
; LINUX-NEXT:    movq $120, 0
; LINUX-NEXT:    retq
;
; LINUX-SKL-LABEL: test6:
; LINUX-SKL:       # %bb.0: # %entry
; LINUX-SKL-NEXT:    movw $0, 8
; LINUX-SKL-NEXT:    movq $120, 0
; LINUX-SKL-NEXT:    retq
;
; LINUX-SKX-LABEL: test6:
; LINUX-SKX:       # %bb.0: # %entry
; LINUX-SKX-NEXT:    movw $0, 8
; LINUX-SKX-NEXT:    movq $120, 0
; LINUX-SKX-NEXT:    retq
;
; LINUX-KNL-LABEL: test6:
; LINUX-KNL:       # %bb.0: # %entry
; LINUX-KNL-NEXT:    movw $0, 8
; LINUX-KNL-NEXT:    movq $120, 0
; LINUX-KNL-NEXT:    retq
;
; LINUX-AVX512BW-LABEL: test6:
; LINUX-AVX512BW:       # %bb.0: # %entry
; LINUX-AVX512BW-NEXT:    movw $0, 8
; LINUX-AVX512BW-NEXT:    movq $120, 0
; LINUX-AVX512BW-NEXT:    retq
entry:
  tail call void @llvm.memcpy.p0.p0.i64(ptr null, ptr @.str2, i64 10, i1 false)
  ret void
}

define void @PR15348(ptr %a, ptr %b) {
; Ensure that alignment of '0' in an @llvm.memcpy intrinsic results in
; unaligned loads and stores.
; DARWIN-LABEL: PR15348:
; DARWIN:       ## %bb.0:
; DARWIN-NEXT:    movzbl 16(%rsi), %eax
; DARWIN-NEXT:    movb %al, 16(%rdi)
; DARWIN-NEXT:    movq (%rsi), %rax
; DARWIN-NEXT:    movq 8(%rsi), %rcx
; DARWIN-NEXT:    movq %rcx, 8(%rdi)
; DARWIN-NEXT:    movq %rax, (%rdi)
; DARWIN-NEXT:    retq
;
; LINUX-LABEL: PR15348:
; LINUX:       # %bb.0:
; LINUX-NEXT:    movzbl 16(%rsi), %eax
; LINUX-NEXT:    movb %al, 16(%rdi)
; LINUX-NEXT:    movq (%rsi), %rax
; LINUX-NEXT:    movq 8(%rsi), %rcx
; LINUX-NEXT:    movq %rcx, 8(%rdi)
; LINUX-NEXT:    movq %rax, (%rdi)
; LINUX-NEXT:    retq
;
; LINUX-SKL-LABEL: PR15348:
; LINUX-SKL:       # %bb.0:
; LINUX-SKL-NEXT:    movzbl 16(%rsi), %eax
; LINUX-SKL-NEXT:    movb %al, 16(%rdi)
; LINUX-SKL-NEXT:    vmovups (%rsi), %xmm0
; LINUX-SKL-NEXT:    vmovups %xmm0, (%rdi)
; LINUX-SKL-NEXT:    retq
;
; LINUX-SKX-LABEL: PR15348:
; LINUX-SKX:       # %bb.0:
; LINUX-SKX-NEXT:    movzbl 16(%rsi), %eax
; LINUX-SKX-NEXT:    movb %al, 16(%rdi)
; LINUX-SKX-NEXT:    vmovups (%rsi), %xmm0
; LINUX-SKX-NEXT:    vmovups %xmm0, (%rdi)
; LINUX-SKX-NEXT:    retq
;
; LINUX-KNL-LABEL: PR15348:
; LINUX-KNL:       # %bb.0:
; LINUX-KNL-NEXT:    movzbl 16(%rsi), %eax
; LINUX-KNL-NEXT:    movb %al, 16(%rdi)
; LINUX-KNL-NEXT:    vmovups (%rsi), %xmm0
; LINUX-KNL-NEXT:    vmovups %xmm0, (%rdi)
; LINUX-KNL-NEXT:    retq
;
; LINUX-AVX512BW-LABEL: PR15348:
; LINUX-AVX512BW:       # %bb.0:
; LINUX-AVX512BW-NEXT:    movzbl 16(%rsi), %eax
; LINUX-AVX512BW-NEXT:    movb %al, 16(%rdi)
; LINUX-AVX512BW-NEXT:    vmovups (%rsi), %xmm0
; LINUX-AVX512BW-NEXT:    vmovups %xmm0, (%rdi)
; LINUX-AVX512BW-NEXT:    retq
  call void @llvm.memcpy.p0.p0.i64(ptr %a, ptr %b, i64 17, i1 false)
  ret void
}

; Memcpys from / to address space 256 should be lowered to appropriate loads /
; stores if small enough.
define void @addrspace256(ptr addrspace(256) %a, ptr addrspace(256) %b) nounwind {
; DARWIN-LABEL: addrspace256:
; DARWIN:       ## %bb.0:
; DARWIN-NEXT:    movq %gs:(%rsi), %rax
; DARWIN-NEXT:    movq %gs:8(%rsi), %rcx
; DARWIN-NEXT:    movq %rcx, %gs:8(%rdi)
; DARWIN-NEXT:    movq %rax, %gs:(%rdi)
; DARWIN-NEXT:    retq
;
; LINUX-LABEL: addrspace256:
; LINUX:       # %bb.0:
; LINUX-NEXT:    movq %gs:(%rsi), %rax
; LINUX-NEXT:    movq %gs:8(%rsi), %rcx
; LINUX-NEXT:    movq %rcx, %gs:8(%rdi)
; LINUX-NEXT:    movq %rax, %gs:(%rdi)
; LINUX-NEXT:    retq
;
; LINUX-SKL-LABEL: addrspace256:
; LINUX-SKL:       # %bb.0:
; LINUX-SKL-NEXT:    vmovups %gs:(%rsi), %xmm0
; LINUX-SKL-NEXT:    vmovups %xmm0, %gs:(%rdi)
; LINUX-SKL-NEXT:    retq
;
; LINUX-SKX-LABEL: addrspace256:
; LINUX-SKX:       # %bb.0:
; LINUX-SKX-NEXT:    vmovups %gs:(%rsi), %xmm0
; LINUX-SKX-NEXT:    vmovups %xmm0, %gs:(%rdi)
; LINUX-SKX-NEXT:    retq
;
; LINUX-KNL-LABEL: addrspace256:
; LINUX-KNL:       # %bb.0:
; LINUX-KNL-NEXT:    vmovups %gs:(%rsi), %xmm0
; LINUX-KNL-NEXT:    vmovups %xmm0, %gs:(%rdi)
; LINUX-KNL-NEXT:    retq
;
; LINUX-AVX512BW-LABEL: addrspace256:
; LINUX-AVX512BW:       # %bb.0:
; LINUX-AVX512BW-NEXT:    vmovups %gs:(%rsi), %xmm0
; LINUX-AVX512BW-NEXT:    vmovups %xmm0, %gs:(%rdi)
; LINUX-AVX512BW-NEXT:    retq
  tail call void @llvm.memcpy.p256.p256.i64(ptr addrspace(256) align 8 %a, ptr addrspace(256) align 8 %b, i64 16, i1 false)
  ret void
}

!llvm.module.flags = !{!0}
!0 = !{i32 1, !"ProfileSummary", !1}
!1 = !{!2, !3, !4, !5, !6, !7, !8, !9}
!2 = !{!"ProfileFormat", !"InstrProf"}
!3 = !{!"TotalCount", i64 10000}
!4 = !{!"MaxCount", i64 10}
!5 = !{!"MaxInternalCount", i64 1}
!6 = !{!"MaxFunctionCount", i64 1000}
!7 = !{!"NumCounts", i64 3}
!8 = !{!"NumFunctions", i64 3}
!9 = !{!"DetailedSummary", !10}
!10 = !{!11, !12, !13}
!11 = !{i32 10000, i64 100, i32 1}
!12 = !{i32 999000, i64 100, i32 1}
!13 = !{i32 999999, i64 1, i32 2}
!14 = !{!"function_entry_count", i64 0}
