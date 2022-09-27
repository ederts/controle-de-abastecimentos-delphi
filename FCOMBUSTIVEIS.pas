unit FCOMBUSTIVEIS;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  dxGDIPlusClasses, Vcl.ExtCtrls, funcoes, Helper.edit, uCOMBUSTIVEL,
  uCOMBUSTIVELDAO;

type
  TfrmCOMBUSTIVEIS = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    lbTitulo: TLabel;
    Label2: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    btnFechar: TBitBtn;
    BitBtn1: TBitBtn;
    edDESC: TEdit;
    Label3: TLabel;
    edPRECO: TEdit;
    Label4: TLabel;
    ckInativo: TCheckBox;
    procedure btnFecharClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edPRECOKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
     CombustivelDAO: TCombustivelDAO;
     Combustivel: TCombustivel;
     procedure PreencherCombustivel;
     procedure PreencherTela;
  public
    { Public declarations }
    vEdicao : Boolean;
    constructor Create(AOwner: TComponent; pCombustivel: TCombustivel);
  end;

var
  frmCOMBUSTIVEIS: TfrmCOMBUSTIVEIS;

implementation

{$R *.dfm}

procedure TfrmCOMBUSTIVEIS.BitBtn1Click(Sender: TObject);
begin
  if edDESC.IsEmpty then
    begin
      Mensagem('Informe uma Descrição!!..');
      edDESC.SetFocus;
      exit;
    end;
  if edPRECO.IsEmpty then
    begin
      Mensagem('Informe um valor!!..');
      edPRECO.SetFocus;
      exit;
    end
  else
    begin
      if StringToFloat(edPRECO.Text)<=0 then
        begin
          Mensagem('O preço informado não é válido, verifique!!..');
          edPRECO.SetFocus;
          exit;
        end;
    end;


 PreencherCombustivel;
 if vEdicao then
   begin
     if CombustivelDAO.Alterar(Combustivel) then
       begin
         Mensagem('Combustível Alterado com Sucesso.');
         Close;
       end;
   end
 else
   begin
     if CombustivelDAO.Inserir(Combustivel) then
       begin
         Mensagem('Combustível Inserido com Sucesso.');
         Close;
       end;
   end;
end;

procedure TfrmCOMBUSTIVEIS.btnFecharClick(Sender: TObject);
begin
   Close;
end;

constructor TfrmCOMBUSTIVEIS.Create(AOwner: TComponent; pCombustivel: TCombustivel);
begin
  if pCombustivel.ID>0 then
    begin
       inherited Create(AOwner);
       vEdicao := True;
       CombustivelDAO := TCombustivelDAO.Create;

      try
        if Assigned(pCombustivel) then
        begin
          Combustivel := pCombustivel;
          PreencherTela;
        end;
      except
        on e: exception do
           raise Exception.Create(E.Message);
      end;
    end
  else
    begin
      inherited Create(AOwner);
      vEdicao := False;
    end;
end;

procedure TfrmCOMBUSTIVEIS.edPRECOKeyPress(Sender: TObject; var Key: Char);
begin
   Key := TestaValor(Sender,Key);
end;

procedure TfrmCOMBUSTIVEIS.FormCreate(Sender: TObject);
begin
  if not vEdicao then
    begin
       Combustivel    := TCombustivel.Create;
       CombustivelDAO := TCombustivelDAO.Create;
    end;
end;

procedure TfrmCOMBUSTIVEIS.FormDestroy(Sender: TObject);
begin
   try
    if Assigned(Combustivel) then
      FreeAndNil(Combustivel);
    if Assigned(CombustivelDAO) then
      FreeAndNil(CombustivelDAO);
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TfrmCOMBUSTIVEIS.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if key=#13 then
     Perform(WM_nextdlgctl,0,0)
  else if Key =  #27 then
     Perform(WM_nextdlgctl,1,0);
end;

procedure TfrmCOMBUSTIVEIS.FormShow(Sender: TObject);
begin
   if vEdicao then
     lbTitulo.Caption := 'Editar Combustível id: '+Combustivel.ID.ToString
   else
     lbTitulo.Caption := 'Cadastrar Combustível';

   edDESC.SetFocus;
end;

procedure TfrmCOMBUSTIVEIS.PreencherCombustivel;
begin
  Combustivel.Descricao  := edDESC.Text;
  Combustivel.PrecoLitro := StringToFloat(edPRECO.Text);
  Combustivel.Inativo    := ckInativo.Checked;
end;

procedure TfrmCOMBUSTIVEIS.PreencherTela;
begin
  edDESC.Text       := Combustivel.Descricao;
  edPRECO.Text      := FloatToString(Combustivel.PrecoLitro,',','###,###,##0.00');
  ckInativo.Checked := Combustivel.Inativo;
end;

end.
