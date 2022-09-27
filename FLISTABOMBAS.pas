unit FLISTABOMBAS;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  dxGDIPlusClasses, Vcl.ExtCtrls, Vcl.StdCtrls, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Vcl.Buttons, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids, System.Generics.Collections,
  Vcl.ComCtrls, Helper.edit, System.Rtti, uBOMBA, uBOMBADAO;

type
  TfrmListaBombas = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    DBGrid1: TDBGrid;
    cdsBombas: TFDMemTable;
    dsBombas: TDataSource;
    cdsBombasID: TIntegerField;
    cdsBombasDESCRICAO: TStringField;
    cdsBombasINATIVO: TStringField;
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
    cdsBombasTANQUE: TStringField;
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
    BombaDAO: TBombaDAO;
    procedure Pesquisar;
    procedure CarregarDados(pListaBomba: TList<TBomba>);
    procedure CarregarDadosRTTI(pListaBomba: TList<TBomba>);
  public
    { Public declarations }
  end;

var
  frmListaBombas: TfrmListaBombas;

implementation

{$R *.dfm}

uses uDMConexao, funcoes, uTANQUES, FBOMBAS;

procedure TfrmListaBombas.btnInserirClick(Sender: TObject);
var
  vBombaNOVA : TBomba;
begin
   try
      vBombaNOVA := TBomba.Create;
       if TfrmBOMBAS(Application.FindComponent('frmBOMBAS')) = nil then
         frmBOMBAS := TfrmBOMBAS.Create(Application,vBombaNOVA);

      frmBOMBAS.vEdicao := False;

      frmBOMBAS.ShowModal;

      Pesquisar;
   finally
     FreeAndNil(vBombaNOVA);
   end;
end;

procedure TfrmListaBombas.btnBuscarClick(Sender: TObject);
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

procedure TfrmListaBombas.Pesquisar;
begin
  try
    //CarregarDados(BombaDAO.Listar(edConteudo.Text,LowerCase(cbCampos.Text)));
    CarregarDadosRTTI(BombaDAO.Listar(edConteudo.Text,LowerCase(cbCampos.Text)));
    if cdsBombas.Active then
       cdsBombas.First;
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TfrmListaBombas.btnEditarClick(Sender: TObject);
begin
   if cdsBombas.IsEmpty then
    begin
       exit;
    end;
   try
    frmBOMBAS := TfrmBOMBAS.Create(Self, BombaDAO.BuscarPorID(cdsBombasID.AsInteger));
    frmBOMBAS.ShowModal;
    Pesquisar;
  finally
    //FreeAndNil(frmBOMBAS);
  end;
end;

procedure TfrmListaBombas.btnExcluirClick(Sender: TObject);
begin
  if cdsBombas.IsEmpty then
    begin
       exit;
    end;

  if Pergunta('Deseja Excluir este Tanque?','S' ) then
    begin
      //if TanqueDAO.Deletar(TanqueDAO.BuscarPorID(cdsTanquesID.AsInteger)) then
      if BombaDAO.DeletarID(cdsBombasID.AsInteger) then
        begin
          Mensagem('Excluído com sucesso.');
          Pesquisar;
        end
      else
        begin
          Mensagem('Erro ao excluir bomba.');
        end;
    end;
end;

procedure TfrmListaBombas.btnFecharClick(Sender: TObject);
begin
   Close;
end;

procedure TfrmListaBombas.CarregarDados(pListaBomba: TList<TBomba>);
var
  I: Integer;
  ItensTemporarios: TListItem;
  Tanque : TTanque;
begin
  if Assigned(pListaBomba) then
    begin
      if cdsBombas.Active then
        begin
         cdsBombas.EmptyDataSet;
         //cdsBombas.Close;
         //cdsBombas.Open;
        end
      else
        begin
         cdsBombas.CreateDataSet;
        end;

      cdsBombas.DisableControls;
      try
        Tanque := Tanque.Create;
        for I := 0 to pListaBomba.Count -1 do
        begin
          if ((not ckInativos.Checked) and  (TTanque(pListaBomba[I]).Inativo)) then
             continue;

          cdsBombas.Append;
          cdsBombasID.AsInteger := TTanque(pListaBomba[I]).ID;
          cdsBombasDESCRICAO.AsString := TTanque(pListaBomba[I]).Descricao;
          if not TTanque(pListaBomba[I]).Inativo then
             cdsBombasINATIVO.AsString := 'Não'
          else
             cdsBombasINATIVO.AsString := 'Sim';
          Tanque :=  TBomba(pListaBomba[i]).Tanque;
          cdsBombasTANQUE.AsString := Tanque.Descricao;
          cdsBombas.Post;
        end;
      finally
        //Combustivel.Free;
      end;
    end
  else
    begin
      if cdsBombas.Active then
         cdsBombas.EmptyDataSet;
      Mensagem('Nenhuma bomba encontrada.');
    end;

  cdsBombas.EnableControls;
end;

procedure TfrmListaBombas.CarregarDadosRTTI(pListaBomba: TList<TBomba>);
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  i : Integer;
begin
  if Assigned(pListaBomba) then
    begin
      if cdsBombas.Active then
        begin
         cdsBombas.EmptyDataSet;
         //cdsBombas.Close;
         //cdsBombas.Open;
        end
      else
        begin
         cdsBombas.CreateDataSet;
        end;

      cdsBombas.DisableControls;
      // Cria o contexto do RTTI
      Contexto := TRttiContext.Create;
      try
        // Obtém as informações de RTTI da classe TTanque
        Tipo := Contexto.GetType(TTanque.ClassInfo);

        for I := 0 to pListaBomba.Count -1 do
          begin
            if ((not ckInativos.Checked) and  (Tipo.GetProperty('Inativo').GetValue(pListaBomba[i]).asBoolean)) then
               continue;

            cdsBombas.Append;
            cdsBombasID.AsInteger := Tipo.GetProperty('ID').GetValue(pListaBomba[i]).asInteger;
            cdsBombasDESCRICAO.AsString := Tipo.GetProperty('Descricao').GetValue(pListaBomba[i]).asString;
            if not Tipo.GetProperty('Inativo').GetValue(pListaBomba[i]).asBoolean then
               cdsBombasINATIVO.AsString := 'Não'
            else
               cdsBombasINATIVO.AsString := 'Sim';
            //cdsBombasCOMBUSTIVEL.AsString := Tipo.GetProperty('Descricao').GetValue(pListaTanque[i].Combustivel).asString;
            cdsBombasTANQUE.AsString := TBomba(pListaBomba[i]).Tanque.Descricao;
            cdsBombas.Post;
          end;
      finally
        Contexto.Free;
      end;
    end
  else
    begin
      if cdsBombas.Active then
         cdsBombas.EmptyDataSet;
      Mensagem('Nenhuma Bomba encontrada.');
    end;

  cdsBombas.EnableControls;
end;

procedure TfrmListaBombas.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
   if cdsBombasINATIVO.AsString='Sim' then
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

procedure TfrmListaBombas.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Action := caFree;
end;

procedure TfrmListaBombas.FormCreate(Sender: TObject);
begin
   BombaDAO  := TBombaDAO.Create;
end;

procedure TfrmListaBombas.FormDestroy(Sender: TObject);
begin
  try
    if Assigned(BombaDAO) then
      FreeAndNil(BombaDAO);
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TfrmListaBombas.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then
     Perform(WM_nextdlgctl,0,0)
  else if Key =  #27 then
     Perform(WM_nextdlgctl,1,0);
end;

procedure TfrmListaBombas.FormShow(Sender: TObject);
begin
  edConteudo.SetFocus;
end;

end.
