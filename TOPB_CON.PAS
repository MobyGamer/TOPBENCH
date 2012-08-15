unit topb_constants;
{Holds common constants/types/records/etc. for TOPBENCH.
MUST NOT have any USES clauses!}

interface

{an attempt to cut down on stack size}
type
  string8=string[8];
  string16=string[16];
  string32=string[32];
  string64=string[64];
  string80=string[80];
  string128=string[128];

  {A video subsystem can be one of these five basic types.  The Tandy/PCjr
  line is an enhanced MC6845-based CGA so it gets folded into CGA.}
  VideoSystems=(unset,MDA,CGA,EGA,MCGA,VGA);
  VidSysLabelArray=array[VideoSystems] of string[4];
{
Introduction
Benchmarking:
  Realtime comparison, Compare two machines
Database Operations:
  Add this computer,
  import results file, import directory\filespec, save, save as, export to .csv
  System Browser (View/delete/edit system)
Setup:
  form with checkboxes soundtoggle, verboselog, colortoggle, realtimespeed (fingerprint accuracy or realtime speed?)
Debug Console
About
}

  userActions=(
  mNull,
  mIntro,
  mBenchMenu,
  mDBMenu,
  mSetup,
  mConsole,
  mAbout,

  mRealtime,
  mCompare,

  mAdd,
  mBrowseName,
  mBrowseSpeed,
  mImport,
  mSave,
  mExport
  );

  menuLookuptype=record
    id:userActions;mhk:word;
    title,blurb:pchar;
  end;
  mainmenuArray=array[mIntro..mAbout] of menuLookuptype;
  benchmenuArray=array[mRealtime..mCompare] of menuLookuptype;
  dbmenuArray=array[mAdd..mExport] of menuLookuptype;

const
  DBFilename='database.ini';
  ConfigFilename='topbench.ini';
  LOGFilename='topbench.log';

  mainmenuLookup:mainmenuArray=(
    (id:mIntro; mhk:ord('I');
    title:' ~I~ntroduction        '; blurb:'A quick explanation of what you can use TOPBENCH for'),
    (id:mBenchMenu; mhk:ord('B');
    title:' ~B~enchmarking        '; blurb:'Benchmark your machine realtime, or compare two systems'),
    (id:mDBMenu; mhk:ord('D');
    title:' ~D~atabase Operations '; blurb:'Add your system to the database; browse, import, and export the database'),
    (id:mSetup; mhk:ord('S');
    title:' ~S~etup               '; blurb:'Change program behavior'),
    (id:mConsole; mhk:ord('M');
    title:' ~M~essage Console     '; blurb:'Shows the message console (meant for debugging)'),
    (id:mAbout; mhk:ord('A');
    title:' ~A~bout               '; blurb:'About this program')
  );

  benchmenuLookup:benchmenuArray=(
    (id:mRealtime; mhk:ord('R');
    title:' ~R~ealtime benchmarking '; blurb:'Continuously benchmarks your system and compares it to the database'),
    (id:mCompare; mhk:ord('C');
    title:' ~C~ompare Systems       '; blurb:'Pick any two systems and see how they compare against each other')
  );

  dbmenuLookup:dbmenuArray=(
    (id:mAdd; mhk:ord('A');
    title:' ~A~dd this system '; blurb:'Takes a fingerprint of this system and adds it to the database'),
    (id:mBrowseName; mhk:ord('N');
    title:' Browse by ~N~ame '; blurb:'System browser; can view, edit, and delete systems from the database'),
    (id:mBrowseSpeed; mhk:ord('P');
    title:' Browse by S~p~eed '; blurb:'System browser; can view, edit, and delete systems from the database'),
    (id:mImport; mhk:ord('I');
    title:' ~I~mport results  '; blurb:'Import one or more database files (usually OUTPUT.INI from the benchmark stub)'),
    (id:mSave; mhk:ord('S');
    title:' ~S~ave database   '; blurb:'Saves the database'),
    (id:mExport; mhk:ord('E');
    title:' ~E~xport to .CSV  '; blurb:'Creates comma-separated file suitable for use with spreadsheets')
  );

  VidSysLabels:VidSysLabelArray=('','MDA','CGA','EGA','MCGA','VGA');

  {text labels for the .ini file; required flags}
  LTestMem='MemoryTest';       LTestMemF    =$01;
  LTestMemEA='MemEATest';      LTestMemEAF  =$02;
  LTestOpcodes='OpcodeTest';   LTestOpcodesF=$04;
  LTestVidMem='VidramTest';    LTestVidMemF =$08;
  LTest3DGames='3DGameTest';   LTest3DGamesF=$10;
  Lbioscrc16='BIOSCRC16';      Lbioscrc16F  =$20;
  Lscore='Score';              LscoreF      =$40;
  LName='Machine';             LNameF       =$80;
  Lcpu='CPU';
  Lcpuspeed='CPUspeed';
  Lvidsystem='VideoSystem';
  Lvidadapter='VideoAdapter';
  Lbiosinfo='BIOSinfo';
  Lbiosdate='BIOSdate';
  LMachineModel='MachineModel';
  LDescription='Description'; {longform description of the system}
  LSubmitter='Submitter';

  RequiredFeatures=LTestMemF+LTestMemEAF+LTestOpcodesF+LTestVidMemF+LTest3DGamesF+Lbioscrc16F+LscoreF+LNameF;

  StubVersion='0.97b';
  StubBanner='TOPBENCH | Benchmark and detection stub | Version '+StubVersion;

  FullVersion='0.3';
  FullBanner='TOPBENCH | 16-bit x86 Benchmarking Suite | Version '+StubVersion;

  DefaultDate=19810801; {birth of IBM PC, roughly}
  MHzLabel=' MHz';

  AboutText:array[0..15] of pChar=(
    '',
    ' The Oldskool PC Benchmark ',
    ' Version '+FullVersion+', 20120812',
    ' Written by Jim Leonard (trixter@oldskool.org)',
    ' ',
    ' Portions of this program written or inspired by:',
    '   Norbert Juffa (TP7 system enhancements)',
    '   Vladimir M. Zakharychev (CPU detection)',
    '   Bob Ainsbury (interface library)',
    '   Eike Frost/EJF (hardware and SVGA detection)',
    '   Richard Wilson (Hercules/Incolor detection)',
    '   Jason Knight (PCjr/Tandy graphics detection)',
    ' ',
    ' Thanks to everyone at the Vintage Computer Forums: ',
    ' http://www.vintage-computer.com/vcforum/forum.php',
    ''
  );

implementation

end.
