Function testMemEA:longint;
begin
{Exercises all effective addressing modes by actually trying to move memory 
with them.  All encodings are included.  Included mostly for the benefit of 
emulator authors.
Accumulator has optimized forms, so both accum and generic reg8/16 tested.}
  asm
    call    _PZTimerOn
    {Make half-assed attempt at not causing trouble by pointing as much as
    we can to known preallocated space.  Chances are low that putting values
    right back into memory won't cause a problem anyway, but it would be just
    my luck that I would somehow manage to land in some interrupt handlers's
    variable area.}
    lea     bx,scratchspace {1K scratch in DS.  disp16=256 and disp8=1.}
    mov     si,bx
    mov     di,bx
    push    bp
    mov     bp,bx
    mov     ax,ds
    mov     es,ax {for exercising segment overrides}

    mov ax,[bx+si]
    mov [bx+si],ax
    mov ax,[bx+di]
    mov [bx+di],ax
    mov ax,[bp+si]
    mov [bp+si],ax
    mov ax,[bp+di]
    mov [bp+di],ax
    mov ax,[si]
    mov [si],ax
    mov ax,[di]
    mov [di],ax
    mov ax,[disp16]
    mov [disp16],ax
    mov ax,[bx]
    mov [bx],ax
    mov ax,[bx+si+disp8]
    mov [bx+si+disp8],ax
    mov ax,[bx+di+disp8]
    mov [bx+di+disp8],ax
    mov ax,[bp+si+disp8]
    mov [bp+si+disp8],ax
    mov ax,[bp+di+disp8]
    mov [bp+di+disp8],ax
    mov ax,[si+disp8]
    mov [si+disp8],ax
    mov ax,[di+disp8]
    mov [di+disp8],ax
    mov ax,[bp+disp8]
    mov [bp+disp8],ax
    mov ax,[bx+disp8]
    mov [bx+disp8],ax
    mov ax,[bx+si+disp16]
    mov [bx+si+disp16],ax
    mov ax,[bx+di+disp16]
    mov [bx+di+disp16],ax
    mov ax,[bp+si+disp16]
    mov [bp+si+disp16],ax
    mov ax,[bp+di+disp16]
    mov [bp+di+disp16],ax
    mov ax,[si+disp16]
    mov [si+disp16],ax
    mov ax,[di+disp16]
    mov [di+disp16],ax
    mov ax,[bp+disp16]
    mov [bp+disp16],ax
    mov ax,[bx+disp16]
    mov [bx+disp16],ax

    seges mov ax,[bx+si]
    seges mov [bx+si],ax
    seges mov ax,[bx+di]
    seges mov [bx+di],ax
    seges mov ax,[bp+si]
    seges mov [bp+si],ax
    seges mov ax,[bp+di]
    seges mov [bp+di],ax
    seges mov ax,[si]
    seges mov [si],ax
    seges mov ax,[di]
    seges mov [di],ax
    seges mov ax,[disp16]
    seges mov [disp16],ax
    seges mov ax,[bx]
    seges mov [bx],ax
    seges mov ax,[bx+si+disp8]
    seges mov [bx+si+disp8],ax
    seges mov ax,[bx+di+disp8]
    seges mov [bx+di+disp8],ax
    seges mov ax,[bp+si+disp8]
    seges mov [bp+si+disp8],ax
    seges mov ax,[bp+di+disp8]
    seges mov [bp+di+disp8],ax
    seges mov ax,[si+disp8]
    seges mov [si+disp8],ax
    seges mov ax,[di+disp8]
    seges mov [di+disp8],ax
    seges mov ax,[bp+disp8]
    seges mov [bp+disp8],ax
    seges mov ax,[bx+disp8]
    seges mov [bx+disp8],ax
    seges mov ax,[bx+si+disp16]
    seges mov [bx+si+disp16],ax
    seges mov ax,[bx+di+disp16]
    seges mov [bx+di+disp16],ax
    seges mov ax,[bp+si+disp16]
    seges mov [bp+si+disp16],ax
    seges mov ax,[bp+di+disp16]
    seges mov [bp+di+disp16],ax
    seges mov ax,[si+disp16]
    seges mov [si+disp16],ax
    seges mov ax,[di+disp16]
    seges mov [di+disp16],ax
    seges mov ax,[bp+disp16]
    seges mov [bp+disp16],ax
    seges mov ax,[bx+disp16]
    seges mov [bx+disp16],ax

    mov al,[bx+si]
    mov [bx+si],al
    mov al,[bx+di]
    mov [bx+di],al
    mov al,[bp+si]
    mov [bp+si],al
    mov al,[bp+di]
    mov [bp+di],al
    mov al,[si]
    mov [si],al
    mov al,[di]
    mov [di],al
    mov al,[disp16]
    mov [disp16],al
    mov al,[bx]
    mov [bx],al
    mov al,[bx+si+disp8]
    mov [bx+si+disp8],al
    mov al,[bx+di+disp8]
    mov [bx+di+disp8],al
    mov al,[bp+si+disp8]
    mov [bp+si+disp8],al
    mov al,[bp+di+disp8]
    mov [bp+di+disp8],al
    mov al,[si+disp8]
    mov [si+disp8],al
    mov al,[di+disp8]
    mov [di+disp8],al
    mov al,[bp+disp8]
    mov [bp+disp8],al
    mov al,[bx+disp8]
    mov [bx+disp8],al
    mov al,[bx+si+disp16]
    mov [bx+si+disp16],al
    mov al,[bx+di+disp16]
    mov [bx+di+disp16],al
    mov al,[bp+si+disp16]
    mov [bp+si+disp16],al
    mov al,[bp+di+disp16]
    mov [bp+di+disp16],al
    mov al,[si+disp16]
    mov [si+disp16],al
    mov al,[di+disp16]
    mov [di+disp16],al
    mov al,[bp+disp16]
    mov [bp+disp16],al
    mov al,[bx+disp16]
    mov [bx+disp16],al

    seges mov al,[bx+si]
    seges mov [bx+si],al
    seges mov al,[bx+di]
    seges mov [bx+di],al
    seges mov al,[bp+si]
    seges mov [bp+si],al
    seges mov al,[bp+di]
    seges mov [bp+di],al
    seges mov al,[si]
    seges mov [si],al
    seges mov al,[di]
    seges mov [di],al
    seges mov al,[disp16]
    seges mov [disp16],al
    seges mov al,[bx]
    seges mov [bx],al
    seges mov al,[bx+si+disp8]
    seges mov [bx+si+disp8],al
    seges mov al,[bx+di+disp8]
    seges mov [bx+di+disp8],al
    seges mov al,[bp+si+disp8]
    seges mov [bp+si+disp8],al
    seges mov al,[bp+di+disp8]
    seges mov [bp+di+disp8],al
    seges mov al,[si+disp8]
    seges mov [si+disp8],al
    seges mov al,[di+disp8]
    seges mov [di+disp8],al
    seges mov al,[bp+disp8]
    seges mov [bp+disp8],al
    seges mov al,[bx+disp8]
    seges mov [bx+disp8],al
    seges mov al,[bx+si+disp16]
    seges mov [bx+si+disp16],al
    seges mov al,[bx+di+disp16]
    seges mov [bx+di+disp16],al
    seges mov al,[bp+si+disp16]
    seges mov [bp+si+disp16],al
    seges mov al,[bp+di+disp16]
    seges mov [bp+di+disp16],al
    seges mov al,[si+disp16]
    seges mov [si+disp16],al
    seges mov al,[di+disp16]
    seges mov [di+disp16],al
    seges mov al,[bp+disp16]
    seges mov [bp+disp16],al
    seges mov al,[bx+disp16]
    seges mov [bx+disp16],al

    mov dx,[bx+si]
    mov [bx+si],dx
    mov dx,[bx+di]
    mov [bx+di],dx
    mov dx,[bp+si]
    mov [bp+si],dx
    mov dx,[bp+di]
    mov [bp+di],dx
    mov dx,[si]
    mov [si],dx
    mov dx,[di]
    mov [di],dx
    mov dx,[disp16]
    mov [disp16],dx
    mov dx,[bx]
    mov [bx],dx
    mov dx,[bx+si+disp8]
    mov [bx+si+disp8],dx
    mov dx,[bx+di+disp8]
    mov [bx+di+disp8],dx
    mov dx,[bp+si+disp8]
    mov [bp+si+disp8],dx
    mov dx,[bp+di+disp8]
    mov [bp+di+disp8],dx
    mov dx,[si+disp8]
    mov [si+disp8],dx
    mov dx,[di+disp8]
    mov [di+disp8],dx
    mov dx,[bp+disp8]
    mov [bp+disp8],dx
    mov dx,[bx+disp8]
    mov [bx+disp8],dx
    mov dx,[bx+si+disp16]
    mov [bx+si+disp16],dx
    mov dx,[bx+di+disp16]
    mov [bx+di+disp16],dx
    mov dx,[bp+si+disp16]
    mov [bp+si+disp16],dx
    mov dx,[bp+di+disp16]
    mov [bp+di+disp16],dx
    mov dx,[si+disp16]
    mov [si+disp16],dx
    mov dx,[di+disp16]
    mov [di+disp16],dx
    mov dx,[bp+disp16]
    mov [bp+disp16],dx
    mov dx,[bx+disp16]
    mov [bx+disp16],dx

    seges mov dx,[bx+si]
    seges mov [bx+si],dx
    seges mov dx,[bx+di]
    seges mov [bx+di],dx
    seges mov dx,[bp+si]
    seges mov [bp+si],dx
    seges mov dx,[bp+di]
    seges mov [bp+di],dx
    seges mov dx,[si]
    seges mov [si],dx
    seges mov dx,[di]
    seges mov [di],dx
    seges mov dx,[disp16]
    seges mov [disp16],dx
    seges mov dx,[bx]
    seges mov [bx],dx
    seges mov dx,[bx+si+disp8]
    seges mov [bx+si+disp8],dx
    seges mov dx,[bx+di+disp8]
    seges mov [bx+di+disp8],dx
    seges mov dx,[bp+si+disp8]
    seges mov [bp+si+disp8],dx
    seges mov dx,[bp+di+disp8]
    seges mov [bp+di+disp8],dx
    seges mov dx,[si+disp8]
    seges mov [si+disp8],dx
    seges mov dx,[di+disp8]
    seges mov [di+disp8],dx
    seges mov dx,[bp+disp8]
    seges mov [bp+disp8],dx
    seges mov dx,[bx+disp8]
    seges mov [bx+disp8],dx
    seges mov dx,[bx+si+disp16]
    seges mov [bx+si+disp16],dx
    seges mov dx,[bx+di+disp16]
    seges mov [bx+di+disp16],dx
    seges mov dx,[bp+si+disp16]
    seges mov [bp+si+disp16],dx
    seges mov dx,[bp+di+disp16]
    seges mov [bp+di+disp16],dx
    seges mov dx,[si+disp16]
    seges mov [si+disp16],dx
    seges mov dx,[di+disp16]
    seges mov [di+disp16],dx
    seges mov dx,[bp+disp16]
    seges mov [bp+disp16],dx
    seges mov dx,[bx+disp16]
    seges mov [bx+disp16],dx

    mov dl,[bx+si]
    mov [bx+si],dl
    mov dl,[bx+di]
    mov [bx+di],dl
    mov dl,[bp+si]
    mov [bp+si],dl
    mov dl,[bp+di]
    mov [bp+di],dl
    mov dl,[si]
    mov [si],dl
    mov dl,[di]
    mov [di],dl
    mov dl,[disp16]
    mov [disp16],dl
    mov dl,[bx]
    mov [bx],dl
    mov dl,[bx+si+disp8]
    mov [bx+si+disp8],dl
    mov dl,[bx+di+disp8]
    mov [bx+di+disp8],dl
    mov dl,[bp+si+disp8]
    mov [bp+si+disp8],dl
    mov dl,[bp+di+disp8]
    mov [bp+di+disp8],dl
    mov dl,[si+disp8]
    mov [si+disp8],dl
    mov dl,[di+disp8]
    mov [di+disp8],dl
    mov dl,[bp+disp8]
    mov [bp+disp8],dl
    mov dl,[bx+disp8]
    mov [bx+disp8],dl
    mov dl,[bx+si+disp16]
    mov [bx+si+disp16],dl
    mov dl,[bx+di+disp16]
    mov [bx+di+disp16],dl
    mov dl,[bp+si+disp16]
    mov [bp+si+disp16],dl
    mov dl,[bp+di+disp16]
    mov [bp+di+disp16],dl
    mov dl,[si+disp16]
    mov [si+disp16],dl
    mov dl,[di+disp16]
    mov [di+disp16],dl
    mov dl,[bp+disp16]
    mov [bp+disp16],dl
    mov dl,[bx+disp16]
    mov [bx+disp16],dl

    seges mov dl,[bx+si]
    seges mov [bx+si],dl
    seges mov dl,[bx+di]
    seges mov [bx+di],dl
    seges mov dl,[bp+si]
    seges mov [bp+si],dl
    seges mov dl,[bp+di]
    seges mov [bp+di],dl
    seges mov dl,[si]
    seges mov [si],dl
    seges mov dl,[di]
    seges mov [di],dl
    seges mov dl,[disp16]
    seges mov [disp16],dl
    seges mov dl,[bx]
    seges mov [bx],dl
    seges mov dl,[bx+si+disp8]
    seges mov [bx+si+disp8],dl
    seges mov dl,[bx+di+disp8]
    seges mov [bx+di+disp8],dl
    seges mov dl,[bp+si+disp8]
    seges mov [bp+si+disp8],dl
    seges mov dl,[bp+di+disp8]
    seges mov [bp+di+disp8],dl
    seges mov dl,[si+disp8]
    seges mov [si+disp8],dl
    seges mov dl,[di+disp8]
    seges mov [di+disp8],dl
    seges mov dl,[bp+disp8]
    seges mov [bp+disp8],dl
    seges mov dl,[bx+disp8]
    seges mov [bx+disp8],dl
    seges mov dl,[bx+si+disp16]
    seges mov [bx+si+disp16],dl
    seges mov dl,[bx+di+disp16]
    seges mov [bx+di+disp16],dl
    seges mov dl,[bp+si+disp16]
    seges mov [bp+si+disp16],dl
    seges mov dl,[bp+di+disp16]
    seges mov [bp+di+disp16],dl
    seges mov dl,[si+disp16]
    seges mov [si+disp16],dl
    seges mov dl,[di+disp16]
    seges mov [di+disp16],dl
    seges mov dl,[bp+disp16]
    seges mov [bp+disp16],dl
    seges mov dl,[bx+disp16]
    seges mov [bx+disp16],dl

    {restore our frame}
    pop     bp

    call    _PZTimerOff
  end;
  testMemEA:=_PZTimerCount;
end;
