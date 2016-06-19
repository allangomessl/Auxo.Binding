# Data Binding Libary

* Dependencies
  * Auxo.Core
  * Auxo.Access

```json
{
  "Name": "Allan Gomes",
  "Age": 24,
  "Contact": {
    "Number": "8588888888"
  }
}
```

```delphi
var 
  binding: IComponentBinding;
  source: IRecord; //<-- { Json, XML, TObject }
  
  //Compoents
  edtName: TcxTextEdit;    //<-- DevExpress Component { prop: Value: string }
  edtAge: TcxSpinEdit;     //<-- DevExpress Component { prop: Value: Double }
  edtContactNumber: TEdit; //<-- Delphi VCL Component { prop: Text: string }

begin
  binding.Source := source;
  binding[edtName, 'Name'];
  binding[edtContactNumer, 'Contact.Number'];
  
  binding.ToControls;
  binding.ToSource;
end;
```

* This library also has a visual component
  
