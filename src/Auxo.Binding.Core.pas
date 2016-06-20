unit Auxo.Binding.Core;

interface

uses
  Auxo.Access.Component, System.Classes, Auxo.Access.Core, System.Generics.Collections;

type
  IComponentBinding = interface
    procedure ToControls;
    procedure ToSource;
    function Bind(Name: string; Comp: TComponent): IComponentBinding;
    procedure SetComponent(Name: string; const Value: TComponent);
    procedure SetName(Comp: TComponent; const Value: string);
    procedure SetSource(const Value: IRecord);
    property Items[Name: string; Comp: TComponent]: IComponentBinding read Bind; default;
    property Items[Name: string]: TComponent write SetComponent; default;
    property Items[Comp: TComponent]: string write SetName; default;
  end;

  TComponentBinding = class(TObject, IComponentBinding)
  private
    FSource: IRecord;
    FBindings: TDictionary<TComponent, string>;
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    procedure SetComponent(Name: string; const Value: TComponent);
    procedure SetName(Comp: TComponent; const Value: string);
    procedure SetSource(const Value: IRecord);
  public
    function Bind(Name: string; Comp: TComponent): IComponentBinding;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    property Items[Name: string; Comp: TComponent]: IComponentBinding read Bind; default;
    property Items[Name: string]: TComponent write SetComponent; default;
    property Items[Comp: TComponent]: string write SetName; default;
    property Source: IRecord read FSource write SetSource;
    procedure ToControls;
    procedure ToSource;
  end;

implementation

{ TComponentBinding }

procedure TComponentBinding.AfterConstruction;
begin
  inherited;
  FBindings := TDictionary<TComponent, string>.Create;
end;

procedure TComponentBinding.BeforeDestruction;
begin
  inherited;
  FBindings.Free;
end;

function TComponentBinding.Bind(Name: string; Comp: TComponent): IComponentBinding;
begin
  Result := Self;
  FBindings.Add(Comp, Name);
end;

procedure TComponentBinding.ToControls;
var
  bnd: TPair<TComponent, string>;
begin
  for bnd in FBindings do
    TAccess.SetValue(bnd.Key, FSource[bnd.Value]);
end;

procedure TComponentBinding.ToSource;
var
  bnd: TPair<TComponent, string>;
begin
  for bnd in FBindings do
    FSource[bnd.Value] := TAccess.GetValue(bnd.Key);
end;

function TComponentBinding.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE
end;

procedure TComponentBinding.SetComponent(Name: string; const Value: TComponent);
begin
  if FBindings.ContainsKey(Value) then
    FBindings[Value] := Name
  else
    FBindings.Add(Value, Name);
end;

procedure TComponentBinding.SetName(Comp: TComponent; const Value: string);
begin
  if FBindings.ContainsKey(Comp) then
    FBindings[Comp] := Value
  else
    FBindings.Add(Comp, Value);
end;

procedure TComponentBinding.SetSource(const Value: IRecord);
begin
  FSource := Value;
end;

function TComponentBinding._AddRef: Integer;
begin
  Result := -1;
end;

function TComponentBinding._Release: Integer;
begin
  Result := -1;
end;

end.
