var
 i:word;
 f:file;
Begin
 assign(f,'256.txt');
 rewrite(f,1);
 for i:=0 to $FF do
  begin
   BlockWrite(f,char(i),1);
  end;
 close(f);
End.