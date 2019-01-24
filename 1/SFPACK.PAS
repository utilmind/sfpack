{$L SFPACK}
unit sfpack;
interface
function SFastPack(InSeg,OutSeg,SizeIsh:word):word;
function SFastUnPack(InSeg,OutSeg,SizeIsh:word):word;
implementation
function SFastPack(InSeg,OutSeg,SizeIsh:word):word; external;
function SFastUnPack(InSeg,OutSeg,SizeIsh:word):word; external;
End.