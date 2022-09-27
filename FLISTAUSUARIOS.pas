unit FLISTAUSUARIOS;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uUSUARIOSDAO, uUSUARIOS,
  dxGDIPlusClasses, Vcl.ExtCtrls, Vcl.StdCtrls, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Vcl.Buttons, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids, System.Generics.Collections,
  Vcl.ComCtrls, Helper.edit, System.Rtti, FUSUARIOS;

type
  TfrmListaUsuarios = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    DBGrid1: TDBGrid;
    cdsUsuarios: TFDMemTable;
    dsUsuarios: TDataSource;
    cdsUsuariosID: TIntegerField;
    cdsUsuariosNOME: TStringField;
    cdsUsuariosINATIVO: TStringField;
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
  private
    { Private declarations }
    UsuarioDAO: TUsuariosDAO;
    procedure Pesquisar;
    procedure CarregarDados(pListaUsuario: TList<TUsuarios>);
    procedure CarregarDadosRTTI(pListaUsuario: TList<TUsuarios>);
  public
    { Public declarations }
  end;

var
  frmListaUsuarios: TfrmListaUsuarios;

implementation

{$R *.dfm}

uses uDMConexao, funcoes;

procedure TfrmListaUsuarios.btnInserirClick(Sender: TObject);
var
  vUsuarioNOVO : TUsuarios;
begin
   try
      vUsuarioNOVO := TUsuarios.Create;
       if TfrmUSUARIOS(Application.FindComponent('frmUSUARIOS')) = nil then
         frmUSUARIOS := TfrmUSUARIOS.Create(Application,vUsuarioNOVO);

      frmUSUARIOS.vEdicao := False;

      frmUSUARIOS.ShowModal;

      Pesquisar;
   finally
     FreeAndNil(frmUSUARIOS);
     FreeAndNil(vUsuarioNOVO);
   end;
end;

procedure TfrmListaUsuarios.btnBuscarClick(Sender: TObject);
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

procedure TfrmListaUsuarios.Pesquisar;
begin
  try
    //CarregarDados(UsuarioDAO.ListarPorNome(edConteudo.Text,LowerCase(cbCampos.Text)));
    CarregarDadosRTTI(UsuarioDAO.ListarPorNome(edConteudo.Text,LowerCase(cbCampos.Text)));
    if cdsUsuarios.Active then
       cdsUsuarios.First;
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TfrmListaUsuarios.btnEditarClick(Sender: TObject);
begin
   if cdsUsuarios.IsEmpty then
    begin
       exit;
    end;
   try
    frmUSUARIOS := TfrmUSUARIOS.Create(Self, UsuarioDAO.BuscarPorID(cdsUsuariosID.AsInteger));
    frmUSUARIOS.ShowModal;
    Pesquisar;
  finally
    FreeAndNil(frmUSUARIOS);
  end;
end;

procedure TfrmListaUsuarios.btnExcluirClick(Sender: TObject);
begin
  if cdsUsuarios.IsEmpty then
    begin
       exit;
    end;

  if Pergunta('Deseja Excluir este usuário?','S' ) then
    begin
      //if UsuarioDAO.Deletar(UsuarioDAO.BuscarPorID(cdsUsuariosID.AsInteger)) then
      if UsuarioDAO.DeletarID(cdsUsuariosID.AsInteger) then
        begin
          Mensagem('Excluído com sucesso.');
          Pesquisar;
        end
      else
        begin
          Mensagem('Erro ao excluir usuário.');
        end;
    end;
end;

procedure TfrmListaUsuarios.btnFecharClick(Sender: TObject);
begin
   Close;
end;

procedure TfrmListaUsuarios.CarregarDados(pListaUsuario: TList<TUsuarios>);
var
  I: Integer;
  ItensTemporarios: TListItem;
begin
  if Assigned(pListaUsuario) then
    begin
      if cdsUsuarios.Active then
        begin
         cdsUsuarios.EmptyDataSet;
         //cdsUsuarios.Close;
         //cdsUsuarios.Open;
        end
      else
        begin
         cdsUsuarios.CreateDataSet;
        end;

      cdsUsuarios.DisableControls;

      for I := 0 to pListaUsuario.Count -1 do
      begin
        if ((not ckInativos.Checked) and  (TUsuarios(pListaUsuario[I]).Inativo)) then
           continue;

        cdsUsuarios.Append;
        cdsUsuariosID.AsInteger := TUsuarios(pListaUsuario[I]).ID;
        cdsUsuariosNOME.AsString := TUsuarios(pListaUsuario[I]).Nome;
        if not TUsuarios(pListaUsuario[I]).Inativo then
           cdsUsuariosINATIVO.AsString := 'Não'
        else
           cdsUsuariosINATIVO.AsString := 'Sim';
        cdsUsuarios.Post;
      end;
    end
  else
    begin
      cdsUsuarios.EmptyDataSet;
      Mensagem('Nenhum Usuário encontrado.');
    end;

  cdsUsuarios.EnableControls;
end;

procedure TfrmListaUsuarios.CarregarDadosRTTI(pListaUsuario: TList<TUsuarios>);
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  i : Integer;
begin
  if Assigned(pListaUsuario) then
    begin
      if cdsUsuarios.Active then
        begin
         cdsUsuarios.EmptyDataSet;
         //cdsUsuarios.Close;
         //cdsUsuarios.Open;
        end
      else
        begin
         cdsUsuarios.CreateDataSet;
        end;

      cdsUsuarios.DisableControls;
      // Cria o contexto do RTTI
      Contexto := TRttiContext.Create;
      try
        // Obtém as informações de RTTI da classe TUsuarios
        Tipo := Contexto.GetType(TUsuarios.ClassInfo);

        for I := 0 to pListaUsuario.Count -1 do
          begin
            if ((not ckInativos.Checked) and  (Tipo.GetProperty('Inativo').GetValue(pListaUsuario[i]).asBoolean)) then
               continue;

            cdsUsuarios.Append;
            cdsUsuariosID.AsInteger := Tipo.GetProperty('ID').GetValue(pListaUsuario[i]).asInteger;
            cdsUsuariosNOME.AsString := Tipo.GetProperty('Nome').GetValue(pListaUsuario[i]).asString;
            if not Tipo.GetProperty('Inativo').GetValue(pListaUsuario[i]).asBoolean then
               cdsUsuariosINATIVO.AsString := 'Não'
            else
               cdsUsuariosINATIVO.AsString := 'Sim';
            cdsUsuarios.Post;
          end;
      finally
        Contexto.Free;
      end;
    end
  else
    begin
      if cdsUsuarios.Active then
         cdsUsuarios.EmptyDataSet;
      Mensagem('Nenhum Usuário encontrado.');
    end;

  cdsUsuarios.EnableControls;
end;

procedure TfrmListaUsuarios.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
   if cdsUsuariosINATIVO.AsString='Sim' then
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

procedure TfrmListaUsuarios.FormCreate(Sender: TObject);
begin
   UsuarioDAO  := TUsuariosDAO.Create;
end;

procedure TfrmListaUsuarios.FormDestroy(Sender: TObject);
begin
  try
    if Assigned(UsuarioDAO) then
      FreeAndNil(UsuarioDAO);
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TfrmListaUsuarios.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then
     Perform(WM_nextdlgctl,0,0)
  else if Key =  #27 then
     Perform(WM_nextdlgctl,1,0);
end;

procedure TfrmListaUsuarios.FormShow(Sender: TObject);
begin
  edConteudo.SetFocus;
end;

end.
