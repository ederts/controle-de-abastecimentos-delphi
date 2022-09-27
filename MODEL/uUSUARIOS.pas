unit uUSUARIOS;

interface

Type
  TUsuarios = class
  private
    FNome: String;
    FSenha: String;
    FInativo : Boolean;
    FID: Integer;
    procedure SetNome(const Value: String);
    procedure SetSenha(const Value: String);
    procedure SetID(const Value: Integer);
    procedure SetInativo(const Value: Boolean);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create;
    property ID: Integer read FID write SetID;
    property Nome: String read FNome write SetNome;
    property Senha: String read FSenha write SetSenha;
    property Inativo: Boolean read FInativo write SetInativo;
  published
    { published declarations }
  end;

implementation

{ TUsuarios }

constructor TUsuarios.Create;
begin
  FID := 0;
  FNome     := '';
  FSenha  := '';
  FInativo   := False;
end;

procedure TUsuarios.SetInativo(const Value: Boolean);
begin
  FInativo := Value;
end;

procedure TUsuarios.SetID(const Value: Integer);
begin
  FID := Value;

end;

procedure TUsuarios.SetNome(const Value: String);
begin
  FNome := Value
end;

procedure TUsuarios.SetSenha(const Value: String);
begin
  FSenha := Value;
end;

end.
