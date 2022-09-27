unit uCOMBUSTIVEL;

interface

  Type
  TCombustivel = class
  private
    FDescricao: String;
    FPrecoLitro: Double;
    FInativo : Boolean;
    FID: Integer;
    procedure SetDescricao(const Value: String);
    procedure SetPrecoLitro(const Value: Double);
    procedure SetID(const Value: Integer);
    procedure SetInativo(const Value: Boolean);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create;
    property ID: Integer read FID write SetID;
    property Descricao: String read FDescricao write SetDescricao;
    property PrecoLitro: Double read FPrecoLitro write SetPrecoLitro;
    property Inativo: Boolean read FInativo write SetInativo;
  published
    { published declarations }
  end;

implementation

{ TCombustivel }

constructor TCombustivel.Create;
begin
  FID := 0;
  FDescricao     := '';
  FPrecoLitro    := 0.00;
  FInativo   := False;
end;

procedure TCombustivel.SetDescricao(const Value: String);
begin
   FDescricao := Value;
end;

procedure TCombustivel.SetID(const Value: Integer);
begin
   FID := Value;
end;

procedure TCombustivel.SetInativo(const Value: Boolean);
begin
   FInativo := Value;
end;

procedure TCombustivel.SetPrecoLitro(const Value: Double);
begin
   FPrecoLitro := Value;
end;

end.
