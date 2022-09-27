unit uTANQUES;

interface

uses uCOMBUSTIVEL;

Type
  TTanque = class
  private
    FDescricao: String;
    FCombustivel: TCombustivel;
    FInativo : Boolean;
    FID: Integer;
    procedure SetDescricao(const Value: String);
    procedure SetCombustivel(const Value: TCombustivel);
    procedure SetID(const Value: Integer);
    procedure SetInativo(const Value: Boolean);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create;
    Destructor Destroy; Override;
    property ID: Integer read FID write SetID;
    property Descricao: String read FDescricao write SetDescricao;
    property Combustivel: TCombustivel read FCombustivel write SetCombustivel;
    property Inativo: Boolean read FInativo write SetInativo;
  published
    { published declarations }
  end;


implementation

{ TTanque }

constructor TTanque.Create;
begin
  FID := 0;
  FDESCRICAO := '';
  Combustivel := TCombustivel.create;
  FInativo   := False;

end;

destructor TTanque.Destroy;
begin
  Combustivel.Free;
  inherited;
end;

procedure TTanque.SetCombustivel(const Value: TCombustivel);
begin
   FCombustivel := Value;
end;

procedure TTanque.SetDescricao(const Value: String);
begin
   FDescricao := Value;
end;

procedure TTanque.SetID(const Value: Integer);
begin
  FID := Value;
end;

procedure TTanque.SetInativo(const Value: Boolean);
begin
  FInativo := Value;
end;

end.
