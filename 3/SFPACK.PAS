{ Модуль упаковки/распаковки памяти по указателям на сегмент (до 64 Кбайт)
  и упаковки/распаковки файлов (любого размера!)
                Алексей Кузнецов (Hacker) из Киева,  1994-98 }

{$I-}
{$L SFPACK}
unit SFPack;

interface

function SFastPack(SourceSeg,TargetSeg,SourceSize:word):word;
function SFastUnPack(SourceSeg,TargetSeg,SourceSize:word):word;
function PackFile(Source,Target:string):boolean;
function UnPackFile(Source,Target:string):boolean;

implementation

var
  FSize:longint;
  Tmp:word;
  SourceBuf,TargetBuf:pointer;
  SourceFile,TargetFile:file;
  f:file;
  st: string;
  b: BYte;

function SFastPack(SourceSeg,TargetSeg,SourceSize:word):word; external;

function SFastUnPack(SourceSeg,TargetSeg,SourceSize:word):word; external;

function PackFile(Source,Target:string):boolean;
 begin
  GetMem(SourceBuf,$FFFA);
  GetMem(TargetBuf,$FFFF);
  Assign(SourceFile,Source);
  Reset(SourceFile,1);
  FSize:=FileSize(SourceFile);
  Assign(TargetFile,Target);
  Rewrite(TargetFile,1);
  b := 0;
  while FSize<>0 do
   begin
    if FSize>$FFFA then Tmp:=$FFFA
    else Tmp:=FSize;
    dec(FSize,Tmp);
    BlockRead(SourceFile,SourceBuf^,Tmp);
    Str(b, st);
    Assign(f, 'd:\hacker\'+st+'.okc');
    Rewrite(f, 1);
    BlockWrite(f, SourceBuf^, tmp);
    Close(f);
    Tmp:=SFastPack(Seg(SourceBuf^),Seg(TargetBuf^),Tmp);
    Assign(f, 'd:\hacker\'+st+'.ca');
    Rewrite(f, 1);
    BlockWrite(f, TargetBuf^, tmp);
    Close(f);
    inc(b);
    writeln(Tmp);
    BlockWrite(TargetFile,Tmp,2);
    BlockWrite(TargetFile,TargetBuf^,Tmp);
   end;
  Close(TargetFile);
  Close(SourceFile);
  FreeMem(TargetBuf,$FFFF);
  FreeMem(SourceBuf,$FFFA);
  if IOResult=0 then PackFile:=True else PackFile:=False;
 end;

function UnPackFile(Source,Target:string):boolean;
 begin
  GetMem(SourceBuf,$FFFF);
  GetMem(TargetBuf,$FFFA);
  Assign(SourceFile,Source);
  Reset(SourceFile,1);
  FSize:=FileSize(SourceFile);
  Assign(TargetFile,Target);
  Rewrite(TargetFile,1);
  while FSize<>0 do
   begin
    BlockRead(SourceFile,Tmp,2);
    BlockRead(SourceFile,SourceBuf^,Tmp);
    dec(FSize,Tmp+2);
    Tmp:=SFastUnPack(Seg(SourceBuf^),Seg(TargetBuf^),Tmp);
    BlockWrite(TargetFile,TargetBuf^,Tmp);
   end;
  Close(TargetFile);
  Close(SourceFile);
  FreeMem(TargetBuf,$FFFA);
  FreeMem(SourceBuf,$FFFF);
  if IOResult=0 then UnPackFile:=True else UnPackFile:=False;
 end;

End.