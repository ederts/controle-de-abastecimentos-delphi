unit FTANQUES;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  dxGDIPlusClasses, Vcl.ExtCtrls, funcoes, Helper.edit, uCOMBUSTIVEL,
  uCOMBUSTIVELDAO, uTANQUES, uTANQUESDAO, System.Generics.Collections;

type
  TfrmTANQUES = class(TForm)
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
    Label4: TLabel;
    ckInativo: TCheckBox;
    cbCOMBUSTIVEL: TComboBox;
    procedure btnFecharClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
     TanqueDAO: TTanqueDAO;
     Tanque: TTanque;
     procedure PreencherTanque;
     procedure PreencherTela;
    procedure CarregaCombustiveis;
  public
    { Public declarations }
    vEdicao : Boolean;
    constructor Create(AOwner: TComponent; pTanque: TTanque);
  end;

var
  frmTANQUES: TfrmTANQUES;

implementation

{$R *.dfm}

procedure TfrmTANQUES.BitBtn1Click(Sender: TObject);
begin
  if edDESC.IsEmpty then
    begin
      Mensagem('Informe uma Descrição!!..');
      edDESC.SetFocus;
      exit;
    end;
  if cbCOMBUSTIVEL.ItemIndex<=-1 then
    begin
      Mensagem('Informe um combustível!!..');
      cbCOMBUSTIVEL.SetFocus;
      exit;
    end;
 try
   PreencherTanque;
   if vEdicao then
     begin
       if TanqueDAO.Alterar(Tanque) then
         begin
           Mensagem('Tanque Alterado com Sucesso.');
           Close;
         end;
     end
   else
     begin
       if TanqueDAO.Inserir(Tanque) then
         begin
           Mensagem('Tanque Inserido com Sucesso.');
           Close;
         end;
     end;
 except
   on e: exception do
      raise Exception.Create(E.Message);
 end;
end;

procedure TfrmTANQUES.btnFecharClick(Sender: TObject);
begin
   Close;
end;

constructor TfrmTANQUES.Create(AOwner: TComponent; pTanque: TTanque);
begin
  if pTanque.ID>0 then
    begin
       inherited Create(AOwner);
       vEdicao := True;
       TanqueDAO := TTanqueDAO.Create;

      try
        if Assigned(pTanque) then
        begin
          Tanque := pTanque;
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

procedure TfrmTANQUES.FormCreate(Sender: TObject);
begin
  if not vEdicao then
    begin
       Tanque    := TTanque.Create;
       TanqueDAO := TTanqueDAO.Create;
    end;
end;

procedure TfrmTANQUES.FormDestroy(Sender: TObject);
begin
   try
    if Assigned(Tanque) then
      FreeAndNil(Tanque);
    if Assigned(TanqueDAO) then
      FreeAndNil(TanqueDAO);
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TfrmTANQUES.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if key=#13 then
     Perform(WM_nextdlgctl,0,0)
  else if Key =  #27 then
     Perform(WM_nextdlgctl,1,0);
end;

procedure TfrmTANQUES.FormShow(Sender: TObject);
begin
   if vEdicao then
     lbTitulo.Caption := 'Editar Tanque id: '+Tanque.ID.ToString
   else
     lbTitulo.Caption := 'Cadastrar Tanque';

   CarregaCombustiveis;
   if vEdicao then
     PreencherTela;

   edDESC.SetFocus;
end;



procedure TfrmTANQUES.CarregaCombustiveis;
var
  CombustivelDAO: TCombustivelDAO;
  pListaCombustivel1: TList<TCombustivel>;
  i : Integer;
begin
  try
    CombustivelDAO  := TCombustivelDAO.Create;
    cbCOMBUSTIVEL.Items.Clear;
    pListaCombustivel1 := TObjectList<TCombustivel>.Create;
    pListaCombustivel1 := CombustivelDAO.Listar('','descrição');
    for I := 0 to pListaCombustivel1.Count -1 do
      begin
         //Quando é um novo registro só mostra os ativos, se estiver editando mostra também os inativos
         //pois pode ter cadastrado um combustível que foi inativado depois.
         if vEdicao then
           begin
             cbCOMBUSTIVEL.Items.AddObject(pListaCombustivel1[I].Descricao,TObject(pListaCombustivel1[I].ID));
           end
         else
           begin
             if (not TCombustivel(pListaCombustivel1[I]).Inativo) then
               cbCOMBUSTIVEL.Items.AddObject(pListaCombustivel1[I].Descricao,TObject(pListaCombustivel1[I].ID));
           end;
      end;
  finally
    CombustivelDAO.Free;
  end;

end;

procedure TfrmTANQUES.PreencherTanque;
var
  CombustivelDAO: TCombustivelDAO;
begin
  try
    CombustivelDAO  := TCombustivelDAO.Create;
    Tanque.Descricao  := edDESC.Text;
    Tanque.Combustivel := CombustivelDAO.BuscarPorID(Integer(cbCOMBUSTIVEL.Items.Objects[cbCOMBUSTIVEL.ItemIndex]));
    Tanque.Inativo    := ckInativo.Checked;
  finally
    CombustivelDAO.Free;
  end;
end;

procedure TfrmTANQUES.PreencherTela;
begin
  edDESC.Text       := Tanque.Descricao;
  ckInativo.Checked := Tanque.Inativo;
  cbCOMBUSTIVEL.ItemIndex := cbCOMBUSTIVEL.Items.IndexOf(Tanque.Combustivel.Descricao);
end;

end.
