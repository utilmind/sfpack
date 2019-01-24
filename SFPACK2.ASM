        model TPASCAL
public  SFastPack
public  SFastUnPack

;       Предупреждение !!!
;  Размер памяти для распаковки рекомендуется делать больше 256 байт,
;и на 2 байта больше размера исходника.

        codeseg
;       SFastPack
;Expects: Сегмент исходника, Сегмент сжатого кода, Размеp исходника
;Returns: Размеp сжатого кода
proc    SFastPack       Source, Target, SourceSize
; Подготовка...
        cld
        mov     cx, SourceSize
        mov     es, Target
        push    ds
        mov     ds, Source
        mov     si, cx
        dec     si
        lodsb
        inc     ax
        mov     [si], al
        mov     dx, cx
; Проверка исходника (поиск неиспользованого байта)...
        xor     ax, ax
        mov     bx, ax
        mov     si, ax
        mov     di, ax
        mov     cx, 128
rep     stosw
        mov     cx, dx
        inc     ax
        mov     di, bx
Cyc:
        mov     bl, [si]
        inc     si
        mov     es:[bx], al
        loop    Cyc
        mov     cx, 101h
rep     scasb
        xor     si, si
        cmp     cx, si
        je      SmartPack
; Сжатие с идентификационным символом...
        mov     cx, dx
        mov     dx, di
        dec     dx
        mov     di, si
        xchg    dl, dh
        mov     es:[di], dx
        add     di, 2
        jmp short PackCycle1
PackCycle:
        stosb
PackCycle1:
        cmp     cx, si
        je      Lock1
        lodsw
        dec     si
        cmp     al, ah
        jne     PackCycle
        cmp     ax, [si+1]
        jne     PackCycle
        mov     es:[di], dh
        inc     di
        stosb
        mov     bx, si
        add     si, 2
Nimnul1:
        inc     si
        cmp     al, [si]
        je      Nimnul1
        mov     ax, si
        sub     ax, bx
        or      ah, ah
        jz      M256_1
        mov     byte ptr es:[di], 0
        inc     di
        stosw
        jmp short PackCycle1
M256_1:
        stosb
        jmp short PackCycle1
; Cжатие при отсутствии идентификационного байта...
SmartPack:
        mov     bx, dx
        mov     cx, bx
        inc     bx
        mov     di, 2
CyclePack:
        cmp     cx, si
        je      Konec
        lodsw
        stosb
        dec     si
        cmp     al, ah
        jne     CyclePack
        cmp     ax, [si+1]
        jne     CyclePack
        cmp     al, [si+3]
        jne     CyclePack
        sub     bx, 2
        mov     es:[bx], di
        mov     dx, si
        add     si, 3
Nimnul:
        inc     si
        cmp     al, [si]
        je      Nimnul
        mov     ax, si
        sub     ax, dx
        or      ah, ah
        jz      M256
        mov     byte ptr es:[di], 0
        inc     di
        stosw
        jmp short CyclePack
M256:
        stosb
        jmp short CyclePack
Konec:
        mov     es:[0], di
        inc     cx
        cmp     bx, cx
        je      Lock1
        sub     cx, bx
        mov     si, bx
        push    es
        pop     ds
rep     movsb
Lock1:
        pop     ds
        mov     ax, di
        ret
endp

;       SFastUnPack
;Expects: Сегмент исходника, Сегмент pазжатого кода, Размеp исходника
;Returns: Размеp pазжатого кода
proc    SFastUnPack     Source1, Target1, SourceSize1
; Подготовка...
        cld
        xor     si, si
        mov     di, si
        mov     bx, SourceSize1
        mov     es, Target1
        push    ds
        mov     ds, Source1
; Проверка метода сжатия...
        mov     dx, [si]
        add     si, 2
        cmp     dl, 0
        jne     UnPackCycle
; Разжатие с идентификационным символом...
CycleUnPack:
        cmp     bx, si
        je      Konec3
        lodsb
        cmp     al, dh
        je      Identify
        stosb
        jmp short CycleUnPack
Identify:
        lodsb
        mov     cl, [si]
        inc     si
        or      cl, cl
        jnz     Low666
        mov     cx, [si]
        add     si, 2
Low666:
        inc     cx
rep     stosb
        jmp short CycleUnPack
; Разжатие без идентификационного символа...
UnPackCycle:
        cmp     dx, bx
        je      Konec2
        sub     bx, 2
        mov     cx, [bx]
        sub     cx, si
        dec     cx
rep     movsb
        lodsb
;        inc     di
        mov     cl, [si]
        inc     si
        or      cl, cl
        jnz     Low1
        mov     cx, [si]
        add     si, 2
Low1:
        inc     cx
rep     stosb
        jmp short UnPackCycle
Konec2:
        mov     cx, dx
        sub     cx, si
rep     movsb
Konec3:
        pop     ds
        mov     ax, di
        ret
endp

        end
