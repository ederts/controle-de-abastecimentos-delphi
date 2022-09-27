unit FLOGIN;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, dxGDIPlusClasses, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Buttons, uUSUARIOS, uUSUARIOSDAO,
  System.Generics.Collections;

type
  TfrmLOGIN = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    btnSalvar: TBitBtn;
    btnFechar: TBitBtn;
    EDUSUARIO: TEdit;
    EDSENHA: TEdit;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure btnFecharClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EDUSUARIOKeyPress(Sender: TObject; var Key: Char);
    procedure btnSalvarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    VSenhaPadrao : String;
    UsuarioDAO: TUsuariosDAO;
    procedure MontaSenhaPadrao;
    { Private declarations }
  public
    { Public declarations }
    vOK : Boolean;
  end;

var
  frmLOGIN: TfrmLOGIN;

implementation

{$R *.dfm}

uses funcoes;

procedure TfrmLOGIN.btnFecharClick(Sender: TObject);
begin
   Close;
   Application.Terminate;
end;

procedure TfrmLOGIN.btnSalvarClick(Sender: TObject);
var
  pListaUsuario: TList<TUsuarios>;
  I: Integer;
  vAchou : Boolean;
begin
   If EDUSUARIO.Text = 'ADMINISTRADOR' then
     begin
       if EDSENHA.Text = VSenhaPadrao then
          Begin
            VUsuario.ID := 0;
            VUsuario.NomeOperador := 'SUPORTE POSTO';
            VUsuario.inativo := False;
            vUsuario.Suporte := True;
            VOk := True;
            Close;
            Exit;
          End;
     end;
   pListaUsuario := UsuarioDAO.ListarPorNome(EDUSUARIO.Text,'nome');
   if Assigned(pListaUsuario) then
     begin
        //todo: listar usuarios do banco e comparar com o digitado localizar pela senha
        vAchou := False;
        for I := 0 to pListaUsuario.Count -1 do
          begin
             if (TUsuarios(pListaUsuario[I]).Senha=EDSENHA.Text) then
               begin
                 vAchou := True;
                 if (TUsuarios(pListaUsuario[I]).Inativo) then
                   begin
                      Mensagem('Usuário Inativo !!!');
                      EDUSUARIO.SetFocus;
                      Exit;
                   end;

                   VUsuario.ID := TUsuarios(pListaUsuario[I]).ID;
                   VUsuario.NomeOperador := TUsuarios(pListaUsuario[I]).Nome;
                   VUsuario.inativo := TUsuarios(pListaUsuario[I]).Inativo;
                   vUsuario.Suporte := False;
                   VOk := True;
                   Close;
                   Exit;
               end;
          end;
        if not vAchou then
          begin
             Mensagem('Senha Inválida !!!');
             EDSENHA.SetFocus;
             Exit;
          end;
     end
   else
     begin
       Mensagem('Usuário Não Encontrado !!!');
       EDUSUARIO.SetFocus;
       Exit;
     end;

end;

procedure TfrmLOGIN.EDUSUARIOKeyPress(Sender: TObject; var Key: Char);
begin
   If ((Key = '''') or (Key = #39)) then
    Begin
      Key := #0;
      exit;
    End
end;

procedure TfrmLOGIN.FormCreate(Sender: TObject);
begin
   UsuarioDAO  := TUsuariosDAO.Create;
end;

procedure TfrmLOGIN.FormDestroy(Sender: TObject);
begin
   try
    if Assigned(UsuarioDAO) then
      FreeAndNil(UsuarioDAO);
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TfrmLOGIN.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if key=#13 then
     Perform(WM_nextdlgctl,0,0)
  else if Key =  #27 then
     Perform(WM_nextdlgctl,1,0);
end;

procedure TfrmLOGIN.FormShow(Sender: TObject);
begin
  MontaSenhaPadrao;

  VOk := False;
  EDUSUARIO.SetFocus;
end;

procedure TfrmLOGIN.MontaSenhaPadrao;
begin
   VSenhapadrao := 'POSTO123';
end;

end.
