uses sfpack;
var
 f:file;
 i,w:word;
 Buf,Buf1,Buf2:pointer;
Begin
 if paramcount<2 then Halt;
 GetMem(Buf,$FFFF);
 GetMem(Buf1,$FFFF);
 GetMem(Buf2,$FFFF);
 assign(f,ParamStr(1));
 reset(f,1);
 w:=FileSize(f);
 BlockRead(f,Buf^,w);
 close(f);
 w:=SFastPack(seg(Buf^),seg(Buf1^),w);
 assign(f,paramstr(2));
 rewrite(f,1);
 BlockWrite(f,Buf1^,w);
 close(f);
 w:=SFastUnPack(seg(Buf1^),seg(Buf2^),w);
 for i:=1 to w do
  if mem[seg(Buf^):i-1]<>mem[seg(Buf2^):i-1] then
   writeln(i-1,' ',mem[seg(Buf^):i-1],' ',mem[seg(Buf2^):i-1]);
 assign(f,paramstr(1));
 rewrite(f,w);
 BlockWrite(f,Buf2^,1);
 close(f)
End.