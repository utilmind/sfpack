{ Pack/unpack testing.  July 1994 by Hacker }
{ Borland Pascal v7.0 for Real Mode         }

uses SFPack2;

var
 f: File;
 i, w: Word;
 Buf, Buf1, Buf2: Pointer;

Begin
  WriteLn('Тестирование сжатия. Первый и третий файлы должны быть равны.');
  if ParamCount < 3 then
   begin
    WriteLn('Пример: sfptest <SourceFile1> <PackedFile2> <TargetFile3>');
    Halt;
   end;
  GetMem(Buf, $FFFF);
  GetMem(Buf1, $FFFF);
  GetMem(Buf2, $FFFF);
  Assign(f, ParamStr(1));
  Reset(f, 1);
  w := FileSize(f);
  BlockRead(f, Buf^, w);
  Close(f);
  w := SFastPack(Seg(Buf^), Seg(Buf1^), w);
  Assign(f, ParamStr(2));
  Rewrite(f, 1);
  BlockWrite(f, Buf1^, w);
  Close(f);
  w := SFastUnPack(Seg(Buf1^), Seg(Buf2^), w);
  Assign(f, ParamStr(3));
  Rewrite(f, w);
  BlockWrite(f, Buf2^, 1);
  Close(f);
  for i := 1 to w do
   if Mem[Seg(Buf^):i - 1] <> Mem[Seg(Buf2^):i - 1] then
    WriteLn('Error: ', i - 1, ' ', Mem[Seg(Buf^):i - 1], ' ', Mem[Seg(Buf2^):i - 1]);
  WriteLn('OK');
End.