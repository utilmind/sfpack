uses sfpack;
Begin
 if paramcount<3 then Halt;
 if not PackFile(ParamStr(1),ParamStr(2)) then
  begin
   writeln('�訡�� �����/�뢮�� �� ᦠ⨨.');
   Halt;
  end;
 if not UnPackFile(ParamStr(2),ParamStr(3)) then
  writeln('�訡�� �����/�뢮�� �� ࠧ��⨨.');
End.