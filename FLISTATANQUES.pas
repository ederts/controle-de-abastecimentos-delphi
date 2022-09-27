unit FLISTATANQUES;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  dxGDIPlusClasses, Vcl.ExtCtrls, Vcl.StdCtrls, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Vcl.Buttons, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids, System.Generics.Collections,
  Vcl.ComCtrls, Helper.edit, System.Rtti, uTANQUESDAO, uTANQUES;

type
  TfrmListaTanques = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    DBGrid1: TDBGrid;
    cdsTanques: TFDMemTable;
    dsTanques: TDataSource;
    cdsTanquesID: TIntegerField;
    cdsTanquesDESCRICAO: TStringField;
    cdsTanquesINATIVO: TStringField;
    cbCampos: TComboBox;
    Label3: TLabel;
    edConteudo: TEdit;
    Label4: TLabel;
    btnBuscar: TBitBtn;
    ckInativos: TCheckBox;
    btnFechar: TBitBtn;
    btnEditar: TBitBtn;
    btnInserir: TBitBtn;
    btnExcluir: TBitBtn;
    cdsTanquesCOMBUSTIVEL: TStringField;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnInserirClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    TanqueDAO: TTanqueDAO;
    procedure Pesquisar;
    procedure CarregarDados(pListaTanque: TList<TTanque>);
    procedure CarregarDadosRTTI(pListaTanque: TList<TTanque>);
  public
    { Public declarations }
  end;

var
  frmListaTanques: TfrmListaTanques;

implementation

{$R *.dfm}

uses uDMConexao, funcoes, FTANQUES, uCOMBUSTIVEL;

procedure TfrmListaTanques.btnInserirClick(Sender: TObject);
var
  vTanqueNOVO : TTanque;
begin
   try
      vTanqueNOVO := TTanque.Create;
       if TfrmTANQUES(Application.FindComponent('frmTANQUES')) = nil then
         frmTANQUES := TfrmTANQUES.Create(Application,vTanqueNOVO);

      frmTANQUES.vEdicao := False;

      frmTANQUES.ShowModal;

      Pesquisar;
   finally
     FreeAndNil(frmTANQUES);
     FreeAndNil(vTanqueNOVO);
   end;
end;

procedure TfrmListaTanques.btnBuscarClick(Sender: TObject);
begin
   if (not edConteudo.isNumero) and (cbCampos.ItemIndex=0) then
     begin
       mensagem('Conteúdo inválido, digite apenas números inteiros.');
       edConteudo.SelectAll;
       edConteudo.SetFocus;
       exit;
     end;
   Pesquisar;
end;

procedure TfrmListaTanques.Pesquisar;
begin
  try
    //CarregarDados(TanqueDAO.Listar(edConteudo.Text,LowerCase(cbCampos.Text)));
    CarregarDadosRTTI(TanqueDAO.Listar(edConteudo.Text,LowerCase(cbCampos.Text)));
    if cdsTanques.Active then
       cdsTanques.First;
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TfrmListaTanques.btnEditarClick(Sender: TObject);
begin
   if cdsTanques.IsEmpty then
    begin
       exit;
    end;
   try
    frmTANQUES := TfrmTANQUES.Create(Self, TanqueDAO.BuscarPorID(cdsTanquesID.AsInteger));
    frmTANQUES.ShowModal;
    Pesquisar;
  finally
    FreeAndNil(frmTANQUES);
  end;
end;

procedure TfrmListaTanques.btnExcluirClick(Sender: TObject);
begin
  if cdsTanques.IsEmpty then
    begin
       exit;
    end;

  if Pergunta('Deseja Excluir este Tanque?','S' ) then
    begin
      //if TanqueDAO.Deletar(TanqueDAO.BuscarPorID(cdsTanquesID.AsInteger)) then
      if TanqueDAO.DeletarID(cdsTanquesID.AsInteger) then
        begin
          Mensagem('Excluído com sucesso.');
          Pesquisar;
        end
      else
        begin
          Mensagem('Erro ao excluir tanque.');
        end;
    end;
end;

procedure TfrmListaTanques.btnFecharClick(Sender: TObject);
begin
   Close;
end;

procedure TfrmListaTanques.CarregarDados(pListaTanque: TList<TTanque>);
var
  I: Integer;
  ItensTemporarios: TListItem;
  Combustivel : TCombustivel;
begin
  if Assigned(pListaTanque) then
    begin
      if cdsTanques.Active then
        begin
         cdsTanques.EmptyDataSet;
         //cdsTanques.Close;
         //cdsTanques.Open;
        end
      else
        begin
         cdsTanques.CreateDataSet;
        end;

      cdsTanques.DisableControls;
      try
        Combustivel := TCombustivel.Create;
        for I := 0 to pListaTanque.Count -1 do
        begin
          if ((not ckInativos.Checked) and  (TTanque(pListaTanque[I]).Inativo)) then
             continue;

          cdsTanques.Append;
          cdsTanquesID.AsInteger := TTanque(pListaTanque[I]).ID;
          cdsTanquesDESCRICAO.AsString := TTanque(pListaTanque[I]).Descricao;
          if not TTanque(pListaTanque[I]).Inativo then
             cdsTanquesINATIVO.AsString := 'Não'
          else
             cdsTanquesINATIVO.AsString := 'Sim';
          Combustivel :=  TTanque(pListaTanque[i]).Combustivel;
          cdsTanquesCOMBUSTIVEL.AsString := Combustivel.Descricao;
          cdsTanques.Post;
        end;
      finally
        //Combustivel.Free;
      end;
    end
  else
    begin
      if cdsTanques.Active then
         cdsTanques.EmptyDataSet;
      Mensagem('Nenhum Tanque encontrado.');
    end;

  cdsTanques.EnableControls;
end;

procedure TfrmListaTanques.CarregarDadosRTTI(pListaTanque: TList<TTanque>);
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  i : Integer;
begin
  if Assigned(pListaTanque) then
    begin
      if cdsTanques.Active then
        begin
         cdsTanques.EmptyDataSet;
         //cdsTanques.Close;
         //cdsTanques.Open;
        end
      else
        begin
         cdsTanques.CreateDataSet;
        end;

      cdsTanques.DisableControls;
      // Cria o contexto do RTTI
      Contexto := TRttiContext.Create;
      try
        // Obtém as informações de RTTI da classe TTanque
        Tipo := Contexto.GetType(TTanque.ClassInfo);

        for I := 0 to pListaTanque.Count -1 do
          begin
            if ((not ckInativos.Checked) and  (Tipo.GetProperty('Inativo').GetValue(pListaTanque[i]).asBoolean)) then
               continue;

            cdsTanques.Append;
            cdsTanquesID.AsInteger := Tipo.GetProperty('ID').GetValue(pListaTanque[i]).asInteger;
            cdsTanquesDESCRICAO.AsString := Tipo.GetProperty('Descricao').GetValue(pListaTanque[i]).asString;
            if not Tipo.GetProperty('Inativo').GetValue(pListaTanque[i]).asBoolean then
               cdsTanquesINATIVO.AsString := 'Não'
            else
               cdsTanquesINATIVO.AsString := 'Sim';
            //cdsTanquesCOMBUSTIVEL.AsString := Tipo.GetProperty('Descricao').GetValue(pListaTanque[i].Combustivel).asString;
            cdsTanquesCOMBUSTIVEL.AsString := TTanque(pListaTanque[i]).Combustivel.Descricao;
            cdsTanques.Post;
          end;
      finally
        Contexto.Free;
      end;
    end
  else
    begin
      if cdsTanques.Active then
         cdsTanques.EmptyDataSet;
      Mensagem('Nenhum Tanque encontrado.');
    end;

  cdsTanques.EnableControls;
end;

procedure TfrmListaTanques.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
   if cdsTanquesINATIVO.AsString='Sim' then
   begin
      dbGrid1.Canvas.Font.Style := dbGrid1.Canvas.Font.Style + [fsStrikeOut];
      DBGrid1.Canvas.Font.Color := clGray;
   end
   else
   begin
      DBGrid1.Canvas.Font.Color := clWindowText;
   end;
   PintaGrid(Sender,Rect,DataCol,Column,State);
end;

procedure TfrmListaTanques.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Action := caFree;
end;

procedure TfrmListaTanques.FormCreate(Sender: TObject);
begin
   TanqueDAO  := TTanqueDAO.Create;
end;

procedure TfrmListaTanques.FormDestroy(Sender: TObject);
begin
  try
    if Assigned(TanqueDAO) then
      FreeAndNil(TanqueDAO);
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TfrmListaTanques.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then
     Perform(WM_nextdlgctl,0,0)
  else if Key =  #27 then
     Perform(WM_nextdlgctl,1,0);
end;

procedure TfrmListaTanques.FormShow(Sender: TObject);
begin
  edConteudo.SetFocus;
end;

end.
