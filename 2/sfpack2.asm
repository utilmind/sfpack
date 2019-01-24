; --------------
; Super fast packer/unpacker. Compression method - modified RLE
; Copyright (c), July 1994 by Aleksey Kuznetsov (Kiev, Ukraine)
; --------------
; This code is FOR NONCOMMERCIAL USE ONLY: February, 25, 1999
; --------------
; Author:   UtilMind Solutions
; E-mail:   info@utilmind.com
; Homepage: http://www.utilmind.com
; --------------

	model TPASCAL
public	SFastPack
public	SFastUnPack

; 	 Warning !!!
; Size of one block of memory should not exceed 64 Kb
; The size of memory for unpacking is recommended to make more than 256 bytes,
; And on 2 bytes there is more then source size.

	codeseg
;	SFastPack
;Expects: Source segment, Target segment, Source size
;Returns: Target packed size
proc	SFastPack	Source, Target, SourceSize
; Preparation...
	cld
	mov	cx, SourceSize
	mov	es, Target
	push	ds
	mov	ds, Source
	mov	si, cx
	dec	si
	lodsb
	inc	ax
	mov	[si], al
	mov	dx, cx
; Checking source (search not used byte)...
	xor	ax, ax
	mov	bx, ax
	mov	si, ax
	mov	di, ax
	mov	cx, 128
rep	stosw
	mov	cx, dx
	inc	ax
	mov	di, bx
Cyc:
	mov	bl, [si]
	inc	si
	mov	es:[bx], al
	loop	Cyc
	mov	cx, 101h
rep	scasb
	xor	si, si
	cmp	cx, si
	je	SmartPack
; Copressing with identification symbol...
	mov	cx, dx
	mov	dx, di
	dec	dx
	mov	di, si
;	xchg	dl, dh		; FIX: 12 May, 2002
	mov	es:[di], dx
	add	di, 2
	jmp short PackCycle1
PackCycle:
	stosb
PackCycle1:
	cmp	cx, si
	je	Lock1
	lodsw
	dec	si
	cmp	al, ah
	jne	PackCycle
	cmp	ax, [si+1]
	jne	PackCycle
	mov	es:[di], dl	; FIX: 12 May, 2002
	inc	di
	stosb
	mov	bx, si
	add	si, 2
Nimnul1:
	inc	si
	cmp	al, [si]
	je	Nimnul1
	mov	ax, si
	sub	ax, bx
	or	ah, ah
	jz	M256_1
	mov	byte ptr es:[di], 0
	inc	di
	stosw
	jmp short PackCycle1
M256_1:
	stosb
	jmp short PackCycle1
; Compressing without identification symbol...
SmartPack:
	mov	bx, dx
	mov	cx, bx
	inc	bx
	mov	di, 2
CyclePack:
	cmp	cx, si
	je	Konec
	lodsw
	stosb
	dec	si
	cmp	al, ah
	jne	CyclePack
	cmp	ax, [si+1]
	jne	CyclePack
	cmp	al, [si+3]
	jne	CyclePack
	sub	bx, 2
	mov	es:[bx], di
	mov	dx, si
	add	si, 3
Nimnul:
	inc	si
	cmp	al, [si]
	je	Nimnul
	mov	ax, si
	sub	ax, dx
	or	ah, ah
	jz	M256
	mov	byte ptr es:[di], 0
	inc	di
	stosw
	jmp short CyclePack
M256:
	stosb
	jmp short CyclePack
Konec:
	mov	es:[0], di
	inc	cx
	cmp	bx, cx
	je	Lock1
	sub	cx, bx
	mov	si, bx
	push	es
	pop	ds
rep	movsb
Lock1:
	pop	ds
	mov	ax, di
	ret
endp

;	SFastUnPack
;Expects: Source segment, Target (packed) segment, Source (unpacked) size
;Returns: Target (unpacked) size
proc	SFastUnPack	Source1, Target1, SourceSize1
; Preparation...
	cld
	xor	si, si
	mov	di, si
	mov	bx, SourceSize1
	mov	es, Target1
	push	ds
	mov	ds, Source1
; Checking the compress method...
	mov	dx, [si]
	add	si, 2
	cmp	dh, 0		; FIX: 12 May, 2002
	jne	UnPackCycle
; Decompressing with identification symbol...
CycleUnPack:
	cmp	bx, si
	je	Konec3
	lodsb
	cmp	al, dl		; FIX: 12 May, 2002
	je	Identify
	stosb
	jmp short CycleUnPack
Identify:
	lodsb
	mov	cl, [si]
	inc	si
	or	cl, cl
	jnz	Low666
	mov	cx, [si]
	add	si, 2
Low666:
	inc	cx
rep	stosb
	jmp short CycleUnPack
; Decompressing without identification symbol...
UnPackCycle:
	cmp	dx, bx
	je	Konec2
	sub	bx, 2
	mov	cx, [bx]
	sub	cx, si
	dec	cx
rep	movsb
	lodsb
	mov	cl, [si]
	inc	si
	or	cl, cl
	jnz	Low1
	mov	cx, [si]
	add	si, 2
Low1:
	inc	cx
rep	stosb
	jmp short UnPackCycle
Konec2:
	mov	cx, dx
	sub	cx, si
rep	movsb
Konec3:
	pop	ds
	mov	ax, di
	ret
endp

	end