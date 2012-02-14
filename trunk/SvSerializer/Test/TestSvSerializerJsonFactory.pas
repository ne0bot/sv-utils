﻿unit TestSvSerializerJsonFactory;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, SysUtils, SvSerializer, SvSerializerJsonFactory,
  Classes, Generics.Collections, Graphics, uSvStrings, DB, MidasLib, DBClient;

type
  TDemoEnum = (deOne, deTwo, deThree);

  TNumbers = set of TDemoEnum;

  TMyRec = record
  private
    FString: string;
    FInt: Integer;
    FDouble: Double;
    procedure SetString(const Value: string);
    procedure SetInt(const Value: Integer);
  public
    [SvSerialize]
    property AInt: Integer read FInt write SetInt;
    [SvSerialize]
    property AString: string read FString write SetString;
    [SvSerialize]
    property ADouble: Double read FDouble write FDouble;
  end;

  IDemoObj = interface
  ['{045BBB1C-89AC-4FAF-9B60-14DC79CCB5FC}']
    function GetName: string;
    procedure SetName(const Value: string);
    [SvSerialize]
    property Name: string read GetName write SetName;
  end;


  (* say our JQGrid defined as:
  jQuery("#gridid").jqGrid({
    ...
   jsonReader : {
      root:"invdata",
      page: "currpage",
      total: "totalpages",
      records: "totalrecords",
      repeatitems: false,
      id: "0"
   },
  ...
  });
  *)
  TJQGridData = class
  private
    FTotalPages: Integer;
    FCurrPage: Integer;
    FTotalRecords: Integer;
    FInvData: TClientDataset;
  public
    constructor Create(); virtual;
    destructor Destroy; override;

    procedure FillData();
    procedure ClearData();
    function ToJSON(): string;
    procedure FromJSON(const AJSONString: string);


    [SvSerialize('totalpages')]
    property TotalPages: Integer read FTotalPages write FTotalPages;
    [SvSerialize('currpage')]
    property CurrentPage: Integer read FCurrPage write FCurrPage;
    [SvSerialize('totalrecords')]
    property TotalRecords: Integer read FTotalRecords write FTotalRecords;
    [SvSerialize('invdata')]
    property InvData: TClientDataset read FInvData write FInvData;
  end;

  TSimple = class
  private
    FList: TArray<string>;
  public
    property List: TArray<string> read FList write FList;
  end;

  TDemoObj = class(TInterfacedObject, IDemoObj)
  private
    FName: string;
    FTag: Integer;
    FDate: TDateTime;
    FEnumas: TDemoEnum;
    FMas: TArray<string>;
    FValue: Variant;
    FIsValid: Boolean;
    FList: TStrings;
    FList2: TList<Integer>;
    FMyRec: TMyRec;
    FColor: TColor;
    FFont: TFont;
    FIntf: IDemoObj;
    FMeth: TProc;
    FDouble: Double;
    FSet: TNumbers;
    FMas2: TArray<TMyRec>;
    FSvString: TSvString;
    FDict: TDictionary<string, TMyRec>;
    FDataset: TClientDataSet;
    FSimple: TSimple;
    function GetName: string;
    procedure SetName(const Value: string);
  public
    constructor Create();
    destructor Destroy; override;
    [SvSerialize]
    property ASet: TNumbers read FSet write FSet;
    [SvSerialize]
    property Name: string read GetName write SetName;
    [SvSerialize]
    property Tag: Integer read FTag write FTag;
    [SvSerialize]
    property DoubleVal: Double read FDouble write FDouble;
    [SvSerialize]
    property Date: TDateTime read FDate write FDate;
    [SvSerialize]
    property Enumas: TDemoEnum read FEnumas write FEnumas;
    [SvSerialize]
    property Mas: TArray<string> read FMas write FMas;
    [SvSerialize]
    property Mas2: TArray<TMyRec> read FMas2 write FMas2;
    [SvSerialize]
    property Value: Variant read FValue write FValue;
    [SvSerialize]
    property IsValid: Boolean read FIsValid write FIsValid;
    [SvSerialize]
    property List: TStrings read FList write FList;
    [SvSerialize]
    property List2: TList<Integer> read FList2 write FList2;
    [SvSerialize]
    property MyRec: TMyRec read FMyRec write FMyRec;
    [SvSerialize]
    property Color: TColor read FColor write FColor;
    [SvSerialize('MyFont')]
    property Font: TFont read FFont write FFont;
   // [SvSerialize]
    property Intf: IDemoObj read FIntf write FIntf;
    [SvSerialize]
    property Meth: TProc read FMeth write FMeth;
    [SvSerialize]
    property SvString: TSvString read FSvString write FSvString;
    [SvSerialize]
    property Dict: TDictionary<string, TMyRec> read FDict write FDict;
    [SvSerialize]
    property Dataset: TClientDataSet read FDataset write FDataset;
    [SvSerialize]
    property SimpleObj: TSimple read FSimple write FSimple;
  end;
  // Test methods for class TSvJsonSerializerFactory

  TestTSvJsonSerializerFactory = class(TTestCase)
  strict private
    FILE_SERIALIZE: string;
    FSerializer: TSvSerializer;
    FSvJsonSerializerFactory: TSvJsonSerializerFactory;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    //test methods
    procedure TestSerializeAndDeserialize();
    procedure TestAddObjectProperties();
    procedure TestRemoveObject();
    procedure TestSerializeRecord();
    procedure TestEscapeValue();
    procedure TestJQGrid();
    procedure TestSQLiteSerializeDeserialize();
  end;

implementation

uses
  Variants,
  DateUtils,
  TypInfo,
  Rtti,
  Diagnostics,
  SvSerializer.Extensions.SQLite;

const
 // FILE_SERIALIZE = 'TestSerialize.json';


  KEY_VALUE: string = 'Main';
  KEY_DATASET: string = 'Dataset';

  PROP_STRING = 'Some unicode Português " Русский/ Ελληνικά';
  PROP_INTEGER : Integer = MaxInt;
  PROP_DOUBLE: Double = 15865874.1569854;
  PROP_ENUM: TDemoEnum = deThree;
  PROP_BOOLEAN: Boolean = True;
  PROP_COLOR: TColor = clRed;
  PROP_SET: TNumbers = [deTwo, deThree];
  PROP_ARRAY: array[0..2] of string = ('1','2','3');
  PROP_FONTNAME = 'Verdana';
  PROP_FONTSIZE = 25;
  COUNT_ARRAY = 3;

  FIELD_STRING = 'NAME';
  FIELD_INTEGER = 'ID';
  FIELD_DOUBLE = 'DOUBLE';
  FIELD_TDATETIME = 'DATETIME';

{ TDemoObj }

constructor TDemoObj.Create;
begin
  FName := '';
  Tag := 0;
  Date := Now;
  Enumas := deOne;
  FValue := Unassigned;
  FIsValid := False;
  FList := TStringList.Create;
  FList2 := TList<Integer>.Create;
  FFont := TFont.Create;
  FIntf := nil;
  FDict := TDictionary<string,TMyRec>.Create();
  FDataset := TClientDataSet.Create(nil);
  //init dataset
  FDataset.FieldDefs.Add(FIELD_STRING, ftWideString, 50);
  FDataset.FieldDefs.Add(FIELD_INTEGER, ftInteger);
  FDataset.FieldDefs.Add(FIELD_DOUBLE, ftFloat);
  FDataset.FieldDefs.Add(FIELD_TDATETIME, ftDateTime);
  FDataset.CreateDataSet;
  FSimple := TSimple.Create;
  SetLength(FSimple.FList, 0);
end;

destructor TDemoObj.Destroy;
begin
  FList.Free;
  FList2.Free;
  FFont.Free;
  FDict.Free;
  FDataset.Free;
  FSimple.Free;
  inherited;
end;

function TDemoObj.GetName: string;
begin
  Result := FName;
end;

procedure TDemoObj.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TestTSvJsonSerializerFactory.SetUp;
begin
  FSerializer := TSvSerializer.Create(sstJson);
  FSvJsonSerializerFactory := TSvJsonSerializerFactory(FSerializer.Factory);
  FILE_SERIALIZE := 'TestSerialize.json';
end;

procedure TestTSvJsonSerializerFactory.TearDown;
begin
  FSerializer.Free;
  FSvJsonSerializerFactory := nil;
end;

procedure TestTSvJsonSerializerFactory.TestAddObjectProperties;
var
  TestObj: TDemoObj;
begin
  TestObj := TDemoObj.Create;
  try
    TestObj.Name := PROP_STRING;
    TestObj.ASet := PROP_SET;
    TestObj.Value := PROP_DOUBLE;
    FSerializer.AddObjectCustomProperties('Test', TestObj, ['Name', 'ASet', 'Value']);

    FSerializer.Serialize('Test.json');


    TestObj.Free;
    TestObj := TDemoObj.Create;

    FSerializer.AddObjectCustomProperties('Test', TestObj, ['Name', 'Value']);

    FSerializer.DeSerialize('Test.json');

    CheckEqualsString(PROP_STRING, TestObj.Name);
    CheckEquals(PROP_DOUBLE, TestObj.Value);
    CheckFalse(PROP_SET = TestObj.ASet);

  finally
    TestObj.Free;
  end;
end;

procedure TestTSvJsonSerializerFactory.TestEscapeValue;

  function EscapeValue(const AValue: string): string;
  var
    i, ix: Integer;
    AChar: Char;

    procedure AddChars(const AChars: string; var Dest: string; var AIndex: Integer); inline;
    begin
      System.Insert(AChars, Dest, AIndex);
      System.Delete(Dest, AIndex + 2, 1);
      Inc(AIndex);
    end;

    procedure AddUnicodeChars(const AChars: string; var Dest: string; var AIndex: Integer); inline;
    begin
      System.Insert(AChars, Dest, AIndex);
      System.Delete(Dest, AIndex + 6, 1);
      Inc(AIndex, 5);
    end;

  begin
    Result := AValue;
    ix := 1;
    for i := 1 to System.Length(AValue) do
    begin
      AChar :=  AValue[i];
      case AChar of
        '/', '\', '"':
        begin
          System.Insert('\', Result, ix);
          Inc(ix, 2);
        end;
        #8:  //backspace \b
        begin
          AddChars('\b', Result, ix);
        end;
        #9:
        begin
          AddChars('\t', Result, ix);
        end;
        #10:
        begin
          AddChars('\n', Result, ix);
        end;
        #12:
        begin
          AddChars('\f', Result, ix);
        end;
        #13:
        begin
          AddChars('\r', Result, ix);
        end;
        #0 .. #7, #11, #14 .. #31:
        begin
          AddUnicodeChars('\u' + IntToHex(Word(AChar), 4), Result, ix);
        end
        else
        begin
          if Word(AChar) > 255 then
          begin
            AddUnicodeChars('\u' + IntToHex(Word(AChar), 4), Result, ix);
          end
          else
          begin
            Inc(ix);
          end;
        end;
      end;
    end;
  end;

  function JSONWideString(const ws: String): string;
  var
    C: char;
  begin
    result := '"';
    for C in ws do begin
      if ord(C) > 255
      then result := result + '\u' + IntToHex(ord(C), 4) //Format('\u%.04x', [ord(C)])
      else
        case C of
          #0 .. #7, #9, #11, #12, #14 .. #31: result := result + '\u' + IntToHex(ord(C), 4);// Format('\u%.04x', [ord(C)]);
          #8: result := result + '\t';
          #10: result := result + '\n';
          #13: result := result + '\r';
          '"': result := result + '\"';
          '\': result := result + '\\';
        else result := result + C;
        end;
    end;

    result := result + '"';
  end;

var
  sRes: string;
  sw: TStopwatch;
  i: Integer;
  iMs1, iMs2: Int64;

const
  CTITERATIONS = 50000;
  cTest: string = 'Lorem ipsum dolor sit amet consectetuer euismod a "sed" adipiscing neque. Pretium ac Donec id facilisi eget sociis Nullam lacinia pharetra Sed. Eu Vivamus Nullam tincidunt malesuada Morbi ac felis mi Praesent lobortis. Lorem Sed tincidunt at interdum '+
    'Aenean metus Curabitur et metus fames. Suscipit Donec nunc adipiscing ligula id elit nonummy a et. '+#10+
		'Congue Aliquam Nam pede mauris/ laoreet cursus ipsum Praesent congue quis. Vitae cursus ut at orci tellus Aenean Phasellus elit dictumst urna.'+
    ' Lacinia tellus arcu a elit pretium lobortis nec dis elit convallis. Pede congue ut ac eget In orci Nunc In auctor a. Metus'+
    ' penatibus orci nibh Proin et odio habitasse cursus et aliquam. Ac lacinia tortor nibh habitasse augue Vestibulum Quisque wisi. '+#10+
		'Id elit pellentesque quis facilisis et Vestibulum accumsan quis eu "Vivamus". Adipiscing Nam egestas ac'+
    ' hac feugiat a vestibulum rutrum in facilisi. Scelerisque pretium vitae pede nunc mauris mauris congue lobortis metus molestie. Morbi fermentum pretium sagittis Ma'+
    'ecenas risus Integer et Nullam malesuada felis. Laoreet augue Aenean lacus dolor nec arcu congue tristique In feugiat. Cursus tincidunt semper nascetur. '+#10+
		'Auctor et sed dui Nulla nec \faucibus Ut at\ vel et. Est Lorem Lorem orci amet condimentum hendrerit'+
    ' elit Morbi libero Ut. Nunc quis et pulvinar magna fermentum wisi quis molestie mauris ac. Risus condimentum vel morbi id ante est pede penatibus tincidunt Pellentesque'+
    '. Eros pharetra ipsum montes accumsan malesuada ac rhoncus at id vitae. Suspendisse sapien diam id In. '+#10+
		'Aliquet /orci Nam Nam consequat Nam orci est elit neque et. Nulla ac id pretium auctor scelerisque '+
    'nunc nunc platea laoreet ornare. Montes turpis lacinia "Phasellus" tempus lacinia laoreet metus arcu tristique orci. Non tellus turpis urna Donec Phasellus et ut justo'+
    ' adipiscing pharetra. Mauris ridiculus adipiscing justo orci Curabitur Nunc semper eros tristique ipsum. Porttitor hac felis at justo Nulla In Sed tristique mattis. ';
begin
  sw := TStopwatch.StartNew;
  try
    for i := 0 to CTITERATIONS - 1 do
    begin
      sRes := '';
      sRes := EscapeValue(cTest);
    end;
  finally
    sw.Stop;
  end;

  iMs1 := sw.ElapsedMilliseconds;

  sw := TStopwatch.StartNew;
  try
    for i := 0 to CTITERATIONS - 1 do
    begin
      sRes := '';
      sRes := JSONWideString(cTest);
    end;
  finally
    sw.Stop;
  end;

  iMs2 := sw.ElapsedMilliseconds;

  Status(Format('Iterations: %D. 1: %D ms. 2: %D ms.',
    [CTITERATIONS, iMs1, iMs2]));

  CheckTrue(iMs1 < iMs2);
end;

procedure TestTSvJsonSerializerFactory.TestJQGrid;
var
  obj: TJQGridData;
  sJson: TSvString;
begin
  obj := TJQGridData.Create;
  try
    obj.FillData;

    sJson := obj.ToJSON;

    sJson.SaveToFile('JQGrid.json');

    obj.ClearData;

    CheckEquals(0, obj.InvData.RecordCount);

    obj.FromJSON(sJson);

    CheckEquals(10, obj.InvData.RecordCount);
  finally
    obj.Free;
  end;
end;

procedure TestTSvJsonSerializerFactory.TestRemoveObject;
var
  TestObj, TestObj2, temp: TDemoObj;
begin
  TestObj := TDemoObj.Create;
  TestObj2 := TDemoObj.Create;
  try
    FSerializer.AddObject('Test', TestObj);
    FSerializer.AddObject('Test2', TestObj2);

    CheckEquals(2, FSerializer.Count);

    FSerializer.RemoveObject(TestObj);

    CheckEquals(1, FSerializer.Count);

    temp := TDemoObj(FSerializer['Test2']);

    CheckTrue(temp = TestObj2);
  finally
    TestObj.Free;
    TestObj2.Free;
  end;
end;

procedure TestTSvJsonSerializerFactory.TestSerializeAndDeserialize;
var
  TestObj: TDemoObj;
  ARec1, ARec2, ARec3: TMyRec;
  AEnum: TPair<string,TMyRec>;
  i: Integer;
begin
  TestObj := TDemoObj.Create;
  try
    //set our properties

    {$REGION 'Set Properties'}
    //string property
    TestObj.Name  := PROP_STRING;
    //integer property
    TestObj.Tag := PROP_INTEGER;
    //datetime property
    TestObj.Date := Today;
    //double property
    TestObj.DoubleVal := PROP_DOUBLE;
    //enum property
    TestObj.Enumas := PROP_ENUM;
    //boolean property
    TestObj.IsValid := PROP_BOOLEAN;
    //TColor property
    TestObj.Color := PROP_COLOR;
    //set property
    TestObj.ASet := PROP_SET;
    //variant property
    TestObj.Value := PROP_DOUBLE;
    //array property
    TestObj.Mas := TArray<string>.Create('1','2','3');
    //complex array
    ARec1.AString := '1';
    ARec1.AInt := 111;
    ARec2.AString := '2';
    ARec2.AInt := 222;
    ARec3.AString := '3';
    ARec3.AInt := 333;
    TestObj.Mas2 := TArray<TMyRec>.Create(ARec1, ARec2, ARec3);
    //TStrings property
    TestObj.List.AddStrings(TestObj.Mas);
    //Generic List property
    TestObj.List2.AddRange([1,2,3]);
    // record property
    TestObj.MyRec.AString := PROP_STRING;
    TestObj.MyRec.AInt := PROP_INTEGER;
    //TFont property
    TestObj.Font.Name := PROP_FONTNAME;
    TestObj.Font.Size := PROP_FONTSIZE;
    //TSvString property
    TestObj.SvString := PROP_STRING;
    //TDictionary property
    TestObj.Dict.Add(PROP_STRING, ARec1);
    TestObj.Dict.Add('1', ARec2);
   // TestObj.Dict.Add(PROP_STRING, PROP_STRING);
   // TestObj.Dict.Add('1', '111');
    TestObj.SimpleObj.List := TArray<string>.Create(PROP_STRING, PROP_STRING, PROP_STRING);
    //TDataset property
    for i := 1 to 10 do
    begin
      TestObj.FDataset.Append;

      TestObj.FDataset.FieldByName(FIELD_STRING).AsString := PROP_STRING;
      TestObj.FDataset.FieldByName(FIELD_INTEGER).AsInteger := i;
      TestObj.FDataset.FieldByName(FIELD_DOUBLE).AsFloat := PROP_DOUBLE;
      TestObj.FDataset.FieldByName(FIELD_TDATETIME).AsDateTime := Today;

      TestObj.FDataset.Post;
    end;
    {$ENDREGION}


    ///////////////////////////////////////////


  //  FSerializer.AddObject(KEY_DATASET, FDataset);

    FSerializer.AddObject(KEY_VALUE, TestObj);
    //serialize to file
    FSerializer.Serialize(FILE_SERIALIZE);

    CheckTrue(FileExists(FILE_SERIALIZE));

    FSerializer.RemoveObject(KEY_VALUE);
   // FSerializer.RemoveObject(KEY_DATASET);
    CheckTrue(FSerializer.Count = 0);
    //recreate our object to make sure that it's values reset to their initial state
    TestObj.Free;
    TestObj := TDemoObj.Create;
    //add newly created object
    FSerializer.AddObject(KEY_VALUE, TestObj);
    CheckTrue(FSerializer.Count = 1);
    //deserialize from file
    FSerializer.DeSerialize(FILE_SERIALIZE);
    //check our properties


    {$REGION 'Check Properties'}
    //string property
    CheckEqualsString(TestObj.Name, PROP_STRING);
    //integer property
    CheckEquals(TestObj.Tag, PROP_INTEGER);
    //datetime property
    CheckEquals(TestObj.Date, Today);
    //double property
    CheckEquals(TestObj.DoubleVal, PROP_DOUBLE);
    //enum property
    CheckTrue(TestObj.Enumas = PROP_ENUM);
    //boolean property
    CheckTrue(TestObj.IsValid = PROP_BOOLEAN);
    //TColor property
    CheckEquals(TestObj.Color, PROP_COLOR);
    //set property
    CheckTrue(TestObj.ASet = PROP_SET);
    //variant property
    CheckTrue(TestObj.Value = PROP_DOUBLE);
    //array property
    CheckTrue(Length(TestObj.Mas) = COUNT_ARRAY);
    CheckEqualsString('1', TestObj.Mas[0]);
    CheckEqualsString('2', TestObj.Mas[1]);
    CheckEqualsString('3', TestObj.Mas[2]);
    //complex array property
    CheckTrue(Length(TestObj.Mas2) = COUNT_ARRAY);
    CheckEqualsString('1', TestObj.Mas2[0].AString);
    CheckEqualsString('2', TestObj.Mas2[1].AString);
    CheckEqualsString('3', TestObj.Mas2[2].AString);
    CheckEquals(111, TestObj.Mas2[0].AInt);
    CheckEquals(222, TestObj.Mas2[1].AInt);
    CheckEquals(333, TestObj.Mas2[2].AInt);
    //TStrings property
    CheckEquals(COUNT_ARRAY, TestObj.List.Count);
    CheckEqualsString('1', TestObj.List[0]);
    CheckEqualsString('2', TestObj.List[1]);
    CheckEqualsString('3', TestObj.List[2]);
    //Generic List property
    CheckEquals(COUNT_ARRAY, TestObj.List2.Count);
    CheckEquals(1, TestObj.List2[0]);
    CheckEquals(2, TestObj.List2[1]);
    CheckEquals(3, TestObj.List2[2]);
    // record property
    CheckEqualsString(PROP_STRING, TestObj.MyRec.AString);
    CheckEquals(PROP_INTEGER, TestObj.MyRec.AInt);
    //TFont property
    CheckEqualsString(PROP_FONTNAME, TestObj.Font.Name);
    CheckEquals(PROP_FONTSIZE, TestObj.Font.Size);
    //TSvString property
    CheckEqualsString(PROP_STRING, TestObj.SvString);
    //TDictionary property
 //   CheckTrue(TestObj.Dict.ContainsKey(PROP_STRING));
 //   CheckTrue(TestObj.Dict.ContainsValue(PROP_STRING));
    CheckTrue(TestObj.Dict.ContainsKey(PROP_STRING));
    i := 0;
    for AEnum in TestObj.Dict do
    begin
      if i = 1 then
      begin
        CheckEqualsString(PROP_STRING, AEnum.Key);
        CheckEqualsString(ARec1.AString, AEnum.Value.AString);
        CheckEquals(ARec1.AInt, AEnum.Value.AInt);
      end
      else
      begin
        CheckEqualsString('1', AEnum.Key);
        CheckEqualsString(ARec2.AString, AEnum.Value.AString);
        CheckEquals(ARec2.AInt, AEnum.Value.AInt);
      end;

      Inc(i);
    end;
    //obkect and array in it
    CheckEquals(3, Length(TestObj.SimpleObj.List));
    CheckEqualsString(PROP_STRING, TestObj.SimpleObj.List[0]);
    CheckEqualsString(PROP_STRING, TestObj.SimpleObj.List[1]);
    CheckEqualsString(PROP_STRING, TestObj.SimpleObj.List[2]);

    //TDataset property
    CheckEquals(10, TestObj.Dataset.RecordCount);
    TestObj.Dataset.First;

    i := 1;
    while not TestObj.Dataset.Eof do
    begin
      CheckEqualsString(PROP_STRING, TestObj.Dataset.FieldByName(FIELD_STRING).AsString);
      CheckEquals(i, TestObj.Dataset.FieldByName(FIELD_INTEGER).AsInteger);
      CheckEquals(PROP_DOUBLE, TestObj.Dataset.FieldByName(FIELD_DOUBLE).AsFloat);
      CheckEquals(Today, TestObj.Dataset.FieldByName(FIELD_TDATETIME).AsDateTime);

      TestObj.Dataset.Next;
      Inc(i);
    end;
    {$ENDREGION}


  finally
    TestObj.Free;
  end;
end;

const
  JSON_STRING = '{"TMyRec.Main":{"FString":"Some unicode Português \" Русский/ Ελληνικά","FInt":2147483647,"FDouble":15865874.1569854}}';

procedure TestTSvJsonSerializerFactory.TestSerializeRecord;
var
  ARec: TMyRec;
  FString: TSvString;
  FJsonString: string;
begin
  ARec.AString := PROP_STRING;
  ARec.AInt := PROP_INTEGER;
  ARec.ADouble := PROP_DOUBLE;

  FSerializer.Marshall<TMyRec>(ARec, 'Record.json');


  ARec.AString := '';
  ARec.AInt := -1;
  ARec.ADouble := -1;

  ARec := FSerializer.UnMarshall<TMyRec>('Record.json');

  CheckEqualsString(PROP_STRING, ARec.AString);
  CheckEquals(PROP_INTEGER, ARec.AInt);
  CheckEquals(PROP_DOUBLE, ARec.ADouble);

  //test string
  FString.LoadFromFile('Record.json');
  CheckTrue(FString <> '');
  FSerializer.Marshall<TMyRec>(ARec, FJsonString, TEncoding.UTF8);
  CheckEqualsString(FString, FJsonString);
  ARec :=  FSerializer.UnMarshall<TMyRec>(FJsonString, TEncoding.UTF8);
  CheckEqualsString(PROP_STRING, ARec.AString);
  CheckEquals(PROP_INTEGER, ARec.AInt);
  CheckEquals(PROP_DOUBLE, ARec.ADouble);
end;

procedure TestTSvJsonSerializerFactory.TestSQLiteSerializeDeserialize;
begin
  FSerializer.Free;
  FSerializer := TSQLiteSerializer.Create();

  FILE_SERIALIZE := 'test.db3';

  TestSerializeAndDeserialize();
end;

{ TMyRec }

procedure TMyRec.SetInt(const Value: Integer);
begin
  FInt := Value;
end;

procedure TMyRec.SetString(const Value: string);
begin
  FString := Value;
end;

{ TJQGridData }

procedure TJQGridData.ClearData;
begin
  FInvData.First;
  while not FInvData.Eof do
  begin
    FInvData.Delete;
  end;
end;

constructor TJQGridData.Create;
begin
  inherited Create();
  FInvData := TClientDataSet.Create(nil);
  FInvData.FieldDefs.Add('invid', ftInteger);
  FInvData.FieldDefs.Add('invdate',ftDateTime);
  FInvData.FieldDefs.Add('amount',ftFloat);
  FInvData.FieldDefs.Add('tax',ftInteger);
  FInvData.FieldDefs.Add('total',ftFloat);
  FInvData.FieldDefs.Add('note',ftWideString, 255);
  FInvData.CreateDataSet;

  FTotalPages := 2;
  FCurrPage := 1;
  FTotalRecords := 10;
end;

destructor TJQGridData.Destroy;
begin
  FInvData.Free;
  inherited Destroy;
end;

procedure TJQGridData.FillData;
var
  i: Integer;
begin
  for i := 1 to 10 do
  begin
    FInvData.Append;

    FInvData.FieldByName('invid').AsInteger := i;
    FInvData.FieldByName('invdate').AsDateTime := Today;
    FInvData.FieldByName('amount').AsFloat := i * 100;
    FInvData.FieldByName('tax').AsInteger := i + 30;
    FInvData.FieldByName('total').AsFloat := i * 101;
    FInvData.FieldByName('note').AsString := PROP_STRING;

    FInvData.Post;
  end;
end;

procedure TJQGridData.FromJSON(const AJSONString: string);
var
  FSer: TSvSerializer;
begin
  FSer := TSvSerializer.Create();
  try
    FSer.AddObject('', Self);
    FSer.DeSerialize(AJSONString, TEncoding.UTF8);
  finally
    FSer.Free;
  end;
end;

function TJQGridData.ToJSON: string;
var
  FSer: TSvSerializer;
begin
  Result := '';
  FSer := TSvSerializer.Create();
  try
    FSer.AddObject('', Self);
    FSer.Serialize(Result, TEncoding.UTF8);
  finally
    FSer.Free;
  end;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTSvJsonSerializerFactory.Suite);
end.

