unit Auxo.Binding.Component;

interface

uses
  System.Classes, System.Generics.Collections, Auxo.Data.Component, Auxo.Binding.Core, Auxo.Core.Observer, Auxo.Data.Core;

type
  TAuxoBinding = class;

  TAuxoBindLink = class(TCollectionItem)
  private
    FComponent: TComponent;
    FMember: string;
    procedure SetMember(const Value: string);
    procedure SetComponent(const Value: TComponent);
  protected
    function GetDisplayName: string; override;
  public
    procedure Assign(Source: TPersistent); override;
  published
    property Component: TComponent read FComponent write SetComponent;
    property Member: string read FMember write SetMember;
  end;

  TAuxoBinding = class(TComponent, IObserver)
  private
    FSource: TAuxoSource;
    FLinks: TOwnedCollection;
    FBinding: IComponentBinding;
    function GetLink(I: Integer): TAuxoBindLink;
    procedure SetLink(I: Integer; const Value: TAuxoBindLink);
    procedure SetSource(const Value: TAuxoSource);
    procedure Notify(Subject: ISubject; Action: TGUID);
  public
    function Locate(Component: TComponent): Integer;
    procedure AddLink(Component: TComponent);
    procedure RemoveLink(Component: TComponent);
    property Index[I: Integer]: TAuxoBindLink read GetLink write SetLink; default;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  published
    property Links: TOwnedCollection read FLinks write FLinks;
    property Source: TAuxoSource read FSource write SetSource;
  end;

implementation

uses
  System.StrUtils, System.SysUtils;

{ TAuxoBinding }

procedure TAuxoBinding.AddLink(Component: TComponent);
var
  Link: TAuxoBindLink;
begin
  if not Assigned(Component) then
    raise Exception.Create('Um controle válido deve ser informado');

  if Locate(Component) < 0 then;
  begin
    FLinks.BeginUpdate;
    try
      Link := TAuxoBindLink(FLinks.Add);
      Link.Component := Component;
    finally
      FLinks.EndUpdate;
    end;
  end;
end;

procedure TAuxoBinding.AfterConstruction;
begin
  inherited;
  FLinks := TOwnedCollection.Create(Self, TAuxoBindLink);
  FBinding := TComponentBinding.Create;
end;

procedure TAuxoBinding.BeforeDestruction;
begin
  inherited;
  FLinks.Free;
  FBinding := nil;
end;

function TAuxoBinding.GetLink(I: Integer): TAuxoBindLink;
begin
  Result := TAuxoBindLink(FLinks.Items[I]);
end;

function TAuxoBinding.Locate(Component: TComponent): Integer;
begin
  Result := FLinks.Count - 1;
  while (Result >= 0) and (TAuxoBindLink(FLinks.Items[Result]).Component <> Component) do
    Dec(Result);
end;

procedure TAuxoBinding.Notify(Subject: ISubject; Action: TGUID);
var
  I: Integer;
  Link: TAuxoBindLink;
begin
  for I := 0 to FLinks.Count-1 do
  begin
    Link := FLinks.Items[I] as TAuxoBindLink;
    FBinding.Items[Link.Component] := Link.Member;
  end;

  if Action = TAuxoSource.INS_ACTION then
  begin
    FBinding.SetSource(Source.Access);
    FBinding.ToControls;
  end;

  if Action = TAuxoSource.POST_ACTION then
  begin
    FBinding.SetSource(Source.Access);
    FBinding.ToSource;
  end;

  if Action = TAuxoSource.LOAD_ACTION then
  begin
    FBinding.SetSource(Source.Access);
    FBinding.ToControls;
  end;
end;

procedure TAuxoBinding.RemoveLink(Component: TComponent);
var
  I: Integer;
begin
  I := Locate(Component);
  if I >= 0 then
    FLinks.Delete(I);
end;

procedure TAuxoBinding.SetLink(I: Integer; const Value: TAuxoBindLink);
begin
  FLinks.Items[I] := Value;
end;

procedure TAuxoBinding.SetSource(const Value: TAuxoSource);
begin
  if Assigned(FSource) and (FSource <> Value) then
    (FSource as ISubject).UnregisterObserver(Self)
  else if Assigned(Value) then
   (Value as ISubject).RegisterObserver(Self, [TAuxoSource.INS_ACTION, TAuxoSource.POST_ACTION]);
  FSource := Value;
end;

{ TAuxoBindLink }

procedure TAuxoBindLink.Assign(Source: TPersistent);
var
  Link: TAuxoBindLink;
begin
  inherited;
  if Source is TAuxoBindLink then
  begin
    Link := TAuxoBindLink(Source);
    Self.Component := Link.FComponent;
    Self.Member := Link.FMember;
  end;
end;

function TAuxoBindLink.GetDisplayName: string;
begin
  if not Assigned(FComponent) then
    Exit('(null) - ' + FMember);
  Result := FComponent.Name + ' - ' + FMember;
end;

procedure TAuxoBindLink.SetComponent(const Value: TComponent);
begin
  FComponent := Value;
end;

procedure TAuxoBindLink.SetMember(const Value: string);
begin
  FMember := Value;
//  if FComponent = nil then
//    (Collection.Owner as TAuxoBinding).FBinding[FMember] := FComponent
//  else
//;    (Collection.Owner as TAuxoBinding).FBinding[FComponent] := FMember;
end;

end.
