{
Configuration and compile directives for topbench.
Mostly used to disable features and enable overlays for building the stub.
}

{$DEFINE STUB}  {define if you are building the stub}

{$IFDEF STUB}
  {{$DEFINE OVERLAYS}
{$ENDIF}