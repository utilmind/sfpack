{*******************************************************************************

  Advanced Application Controls v2.4
  FILE: acSFPack.pas - routines for ultra fast compression (similar to RLE).

  Copyright (c) 1998-2001 UtilMind Solutions
  All rights reserved.
  E-Mail: info@appcontrols.com, info@utilmind.com
  WWW: http://www.appcontrols.com, http://www.utilmind.com

  The entire contents of this file is protected by International Copyright
Laws. Unauthorized reproduction, reverse-engineering, and distribution of all
or any portion of the code contained in this file is strictly prohibited and
may result in severe civil and criminal penalties and will be prosecuted to
the maximum extent possible under the law.

  Restrictions

  The source code contained within this file and all related files or any
portion of its contents shall at no time be copied, transferred, sold,
distributed, or otherwise made available to other individuals without express
written consent and permission from the UtilMind Solutions.

  Consult the End User License Agreement (EULA) for information on additional
restrictions.

*******************************************************************************}
{$I umDefines.inc}

unit acSFPack;

interface

{$IFNDEF D3}
uses Windows;
{$ENDIF}

function SFPack(Source, Target: Pointer; SourceSize: DWord): DWord; // returns Target size
function SFUnpack(Source, Target: Pointer; SourceSize: DWord): DWord; // returns Target size

function SFPackFile(SourceFileName, TargetFileName: String): Boolean; { Return True if successful }
function SFUnpackFile(SourceFileName, TargetFileName: String): Boolean; { Return True if successful }

implementation

{$L sfpack32.obj}

function SFPack(Source, Target: Pointer; SourceSize: DWord): DWord; external;
function SFUnpack(Source, Target: Pointer; SourceSize: DWord): DWord; external;

function SFPackFile(SourceFileName, TargetFileName: String): Boolean; { Return FALSE if IOError }
var
  Source, Target: Pointer;
  SourceFile, TargetFile: File;
  RequiredMaxSize, TargetFSize, FSize: LongInt;
begin
  AssignFile(SourceFile, SourceFileName);
  Reset(SourceFile, 1);
  FSize := FileSize(SourceFile);

  RequiredMaxSize := FSize + (FSize div $FFFF + 1) * 2;
  GetMem(Source, RequiredMaxSize);
  GetMem(Target, RequiredMaxSize);

  BlockRead(SourceFile, Source^, FSize);
  CloseFile(SourceFile);

  TargetFSize := SFPack(Source, Target, FSize);

  AssignFile(TargetFile, TargetFileName);
  Rewrite(TargetFile, 1);
  { Also, you may put header }
  BlockWrite(TargetFile, FSize, SizeOf(FSize)); { Original file size }
  BlockWrite(TargetFile, Target^, TargetFSize);
  CloseFile(TargetFile);

  FreeMem(Target, RequiredMaxSize);
  FreeMem(Source, RequiredMaxSize);

  Result := IOResult = 0;
end;

function SFUnpackFile(SourceFileName, TargetFileName: String): Boolean; { Return FALSE if IOError }
var
  Source, Target: Pointer;
  SourceFile, TargetFile: File;
  OriginalFileSize, FSize: LongInt;
begin
  AssignFile(SourceFile, SourceFileName);
  Reset(SourceFile, 1);
  FSize := FileSize(SourceFile) - SizeOf(OriginalFileSize);

  { Read header ? }
  BlockRead(SourceFile, OriginalFileSize, SizeOf(OriginalFileSize));

  GetMem(Source, FSize);
  GetMem(Target, OriginalFileSize);

  BlockRead(SourceFile, Source^, FSize);
  CloseFile(SourceFile);

  SFUnpack(Source, Target, FSize);

  AssignFile(TargetFile, TargetFileName);
  Rewrite(TargetFile, 1);       
  BlockWrite(TargetFile, Target^, OriginalFileSize);
  CloseFile(TargetFile);

  FreeMem(Target, OriginalFileSize);
  FreeMem(Source, FSize);

  Result := IOResult = 0;
end;

end.