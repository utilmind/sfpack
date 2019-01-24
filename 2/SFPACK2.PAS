{$L SFPACK2}
unit SFPack2;

interface

function SFastPack(SourceSeg, TargetSeg, SourceSize: Word): Word;
function SFastUnPack(SourceSeg, TargetSeg, SourceSize:word): Word;

implementation

function SFastPack; external;
function SFastUnPack; external;

End.