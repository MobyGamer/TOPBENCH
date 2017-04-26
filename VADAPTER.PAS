{O-,F-}
unit vadapter;
{
OOP wrapper for simple non-VGA video detection code.  (VGA is actually
detected, but no attempt at manufacturer or SVGA model is made.)
Sources for detection routines come from Richard Wilton, Jason Knight,
Jim Leonard, and others.

trixter@oldskool.org, 20111017
}

interface

uses
  objects;

type
  pVideoSubsystem=^tVideoSubsystem;
  tVideoSubsystem=object(TObject)
    NumAdapters:byte;
    HerculesPresent:boolean;
    PrimaryType,PrimaryName,PrimaryDisplay:string;
    SecondaryType,SecondaryName,SecondaryDisplay:string;
    constructor init;
    destructor done; virtual;
  end;

implementation

uses
  strings; {for pchar->string support}

type
  VidType=record
    SubSystem,Display:byte;
  end;
  VidArray=array[0..1] of VidType;

var
  VidInfo:VidArray;

Procedure _VideoID(var foo:VidArray); far; external; {$L videoid.obj}

constructor TVideoSubsystem.Init;
const
  IBMname:array[0..5] of pchar=('(unknown)','MDA','CGA','EGA','MCGA','VGA');
  Hercname:array[0..2] of pchar=('Hercules Graphics Card','Hercules Graphics Card Plus+','Hercules InColor Card');
  Displayname:array[0..5] of PChar=(
  '(unknown)',
  'MDA monochrome display',
  'CGA color display',
  'EGA color display',
  'PS/2 monochrome display',
  'PS/2 color display'
  );

begin
  NumAdapters:=1;
  HerculesPresent:=false;

  {First, call Wilton detection routine}
  _VideoID(VidInfo);

  if (VIDinfo[0].Subsystem AND $80)=$80 {If Hercules, we should populate Name better}
    then begin
      HerculesPresent:=true;
      PrimaryType:='MDA';
      PrimaryName:=strpas(Hercname[VIDinfo[0].Subsystem AND $7F]);
    end
    else begin
      PrimaryType:=strpas(IBMname[VIDinfo[0].Subsystem]);
      PrimaryName:=PrimaryType;
    end;
  PrimaryDisplay:=strpas(displayName[VIDinfo[0].Display]);

  {Is a second adapter present?}
  if VIDinfo[1].Subsystem <> 0 then begin
    inc(NumAdapters);
    SecondaryType:=strpas(IBMname[VIDinfo[1].Subsystem]);
    if (VIDinfo[1].Subsystem AND $80)=$80 {If Hercules, we should populate Name better}
      then begin
        HerculesPresent:=true;
        SecondaryType:='MDA';
        SecondaryName:=strpas(Hercname[VIDinfo[1].Subsystem AND $7F]);
      end
      else SecondaryName:=strpas(IBMname[VIDinfo[1].Subsystem]);
    SecondaryDisplay:=strpas(displayName[VIDinfo[1].Display]);
  end;
end;

destructor TVideoSubsystem.Done;
begin
  Inherited Done;
end;

end.
