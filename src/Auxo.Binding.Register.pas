unit Auxo.Binding.Register;

interface

procedure register;

implementation

uses
  System.Classes, Auxo.Binding.Component;

procedure register;
begin
  RegisterComponents('Auxo', [TAuxoBinding]);
end;

end.
