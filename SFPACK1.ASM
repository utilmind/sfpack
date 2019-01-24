	model TPASCAL
public	SFastPack
public	SFastUnPack

	codeseg
proc	SFastPack	Source, Target, SourceSize
;Expects: Сегмент исходника, Сегмент сжатого кода, Размеp исходника
;Returns: Размеp сжатого кода
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
	mov	bx, cx
	inc	bx
	xor	si, si
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

proc	SFastUnPack	Source1, Target1, SourceSize1
;Expects: Сегмент исходника, Сегмент pазжатого кода, Размеp исходника
;Returns: Размеp pазжатого кода
	cld
	xor	si, si
	mov	di, si
	mov	bx, SourceSize1
	mov	es, Target1
	push	ds
	mov	ds, Source1
	mov	dx, [si]
	add	si, 2
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
	pop	ds
	mov	ax, di
	ret
endp

	end
