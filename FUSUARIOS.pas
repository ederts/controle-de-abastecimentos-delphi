unit FUSUARIOS;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  dxGDIPlusClasses, Vcl.ExtCtrls, uUSUARIOS, uUSUARIOSDAO, funcoes, Helper.edit;

type
  TfrmUSUARIOS = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    lbTitulo: TLabel;
    Label2: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    btnFechar: TBitBtn;
    BitBtn1: TBitBtn;
    edNome: TEdit;
    Label3: TLabel;
    edSenha: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    edConfSenha: TEdit;
    ckInativo: TCheckBox;
    procedure btnFecharClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
     UsuarioDAO: TUsuariosDAO;
     Usuario: TUsuarios;
     procedure PreencherUsuario;
     procedure PreencherTela;
  public
    { Public declarations }
    vEdicao : Boolean;
    constructor Create(AOwner: TComponent; pUsuario: TUsuarios);
  end;

var
  frmUSUARIOS: TfrmUSUARIOS;

implementation

{$R *.dfm}

procedure TfrmUSUARIOS.BitBtn1Click(Sender: TObject);
begin
  if edNome.IsEmpty then
    begin
      Mensagem('Informe um nome de usuário!!..');
      edNome.SetFocus;
      exit;
    end;
  if edSenha.IsEmpty then
    begin
      Mensagem('Informe uma senha!!..');
      edSenha.SetFocus;
      exit;
    end;
  if edSenha.Text <> edConfSenha.Text then
    begin
      Mensagem('Senhas não conferem!!..');
      edSenha.SetFocus;
      exit;
    end;

 PreencherUsuario;
 if vEdicao then
   begin
     if UsuarioDAO.Alterar(Usuario) then
       begin
         Mensagem('Usuário Alterado com Sucesso.');
         Close;
       end;
   end
 else
   begin
     if UsuarioDAO.Inserir(Usuario) then
       begin
         Mensagem('Usuário Inserido com Sucesso.');
         Close;
       end;
   end;
end;

procedure TfrmUSUARIOS.btnFecharClick(Sender: TObject);
begin
   Close;
end;

constructor TfrmUSUARIOS.Create(AOwner: TComponent; pUsuario: TUsuarios);
begin
  if pUsuario.ID>0 then
    begin
       inherited Create(AOwner);
       vEdicao := True;
       UsuarioDAO := TUsuariosDAO.Create;

      try
        if Assigned(pUsuario) then
        begin
          Usuario := pUsuario;
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

procedure TfrmUSUARIOS.FormCreate(Sender: TObject);
begin
  if not vEdicao then
    begin
       Usuario    := TUsuarios.Create;
       UsuarioDao := TUsuariosDAO.Create;
    end;
end;

procedure TfrmUSUARIOS.FormDestroy(Sender: TObject);
begin
   try
    if Assigned(Usuario) then
      FreeAndNil(Usuario);
    if Assigned(UsuarioDAO) then
      FreeAndNil(UsuarioDAO);
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TfrmUSUARIOS.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if key=#13 then
     Perform(WM_nextdlgctl,0,0)
  else if Key =  #27 then
     Perform(WM_nextdlgctl,1,0);
end;

procedure TfrmUSUARIOS.FormShow(Sender: TObject);
begin
   if vEdicao then
     lbTitulo.Caption := 'Editar Usuário id: '+Usuario.ID.ToString
   else
     lbTitulo.Caption := 'Cadastrar Usuário';

   edNome.SetFocus;
end;

procedure TfrmUSUARIOS.PreencherUsuario;
begin
  Usuario.Nome    := edNome.Text;
  Usuario.Senha := edSenha.Text;
  Usuario.Inativo  := ckInativo.Checked;
end;

procedure TfrmUSUARIOS.PreencherTela;
begin
  edNome.Text       := Usuario.Nome;
  edSenha.Text      := Usuario.Senha;
  edConfSenha.Text  := Usuario.Senha;
  ckInativo.Checked := Usuario.Inativo;
end;

end.
