unit Helper.edit;

interface

uses
  vcl.stdCtrls, SysUtils, System.Character;

type
	   TEditCampo = class helper for TEdit
	   public
	      function isNumero: boolean;
        function IsEmpty: boolean;

	end;

implementation

function TEditCampo.IsEmpty: boolean;
begin
   result := Trim(Self.Text) = EmptyStr;
end;

function TEditCampo.isNumero: boolean;
var
  i : Integer;
  vTexto : String;
begin
   Result := True;
   vTexto := Self.Text;
   for I := 1 to Length(vTexto) do
     begin
        if not IsNumber(vTexto[I]) then
          begin
            Result := False;
            break;
          end;
	   end;
end;

end.
