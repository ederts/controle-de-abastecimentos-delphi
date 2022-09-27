unit FCONFBASE;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  System.IniFiles;

Type TRede = Record
     Maquina : String;
     Path : String;
End;

type
  TfrmConfBase = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    sbtnOpen: TSpeedButton;
    edCaminho: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    edServidor: TEdit;
    selarq: TOpenDialog;
    btnTestar: TBitBtn;
    btnSalvar: TBitBtn;
    btnFechar: TBitBtn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnOpenClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnTestarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    vPATH : String;
    function DadosdaRede(Path: String): TRede;
  public
    { Public declarations }
    vCaminho,vServidor : String;
  end;

var
  frmConfBase: TfrmConfBase;
  INI : TIniFile;

implementation

{$R *.dfm}

uses funcoes, uDMConexao;

procedure TfrmConfBase.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Action := caFree;
end;

procedure TfrmConfBase.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then
     Perform(WM_nextdlgctl,0,0)
  else if Key =  #27 then
     Perform(WM_nextdlgctl,1,0);
end;

procedure TfrmConfBase.FormShow(Sender: TObject);
begin
   edCaminho.Text := vCaminho;
   edServidor.Text := vServidor;
end;

procedure TfrmConfBase.sbtnOpenClick(Sender: TObject);
Var
  VTmp : TRede;
begin
  If SelArq.Execute then
  Begin
    vPATH := ExtractFilePath(selarq.FileName);
    VTmp := DadosDaRede(ExtractFilePath(selarq.FileName));
    edCaminho.Text := VTmp.Path;
    edServidor.Text := VTmp.Maquina;
  End;

end;

procedure TfrmConfBase.btnSalvarClick(Sender: TObject);
Var vTMPCaminhoBase:String;
    vTMPDirDados:String;
    vTMPDescBase:String;
    vBaseTmp : String;
begin

   if edCaminho.Text='' then
   begin
      Mensagem('Caminho Obrigatório!!');
      exit;
   end;

   vBaseTmp := 'POSTO.FDB';

   VTmpCaminhoBase := StringReplace(edCaminho.Text+'\' + vBaseTmp,'\\','\',[rfReplaceAll, rfIgnoreCase]);

   VTMPDirDados    := vPATH;



   INI := TINIFILE.Create(ExtractFilePath(Application.ExeName) +'POSTO.INI');
   INI.WriteString('GERAL','BaseDados',VTMPCaminhoBase);
   INI.WriteString('GERAL','Path',VTMPDirDados);
   INI.WriteString('GERAL','Servidor',edServidor.Text);
   INI.WriteString('GERAL','Nome Arquivo',vBaseTmp);
   FreeAndNil(INI);

   carregaDadosConexao;
   try
      dmConexao.conexao.Params.Values['database'] := vCaminhoBase;
      dmConexao.conexao.Params.Values['server'] := vNomeServidor;
      dmConexao.conexao.Connected := True;
   except
      Mensagem('Não foi possível conectar em '+dmConexao.conexao.Params.Values['database']);
   end;

   ModalResult := mrOk;

end;

procedure TfrmConfBase.btnTestarClick(Sender: TObject);
Var
 vBaseTmp : String;
begin

   vBaseTmp := 'POSTO.FDB';
   dmConexao.conexao.Params.Values['database'] := '';
   dmConexao.conexao.Params.Values['server'] := '';

   If not Empty(edServidor.Text) then
     Begin
       dmConexao.conexao.Params.Values['database'] := StringReplace(edCaminho.Text+'\' + vBaseTmp,'\\','\',[rfReplaceAll, rfIgnoreCase]);
       dmConexao.conexao.Params.Values['server'] := edServidor.Text;
     End
   Else
     Begin
       if Pos(VBaseDados,edCaminho.Text) <> 0 then
         dmConexao.conexao.Params.Values['database'] := edCaminho.Text
       Else
         dmConexao.conexao.Params.Values['database'] := StringReplace(edCaminho.Text+'\' + vBaseTmp,'\\','\',[rfReplaceAll, rfIgnoreCase]);
     End;
  Try
   Try

     dmConexao.conexao.Connected := True;

     Mensagem('Conexão Efetuada com Sucesso !!!');
     //dmConexao.conexao.Connected := False;
   Except
     on E: Exception do
     Begin
       MessageDlg('Erro de conexão !!!'+#13+E.Message,mtError,[mbOk],0);
       If Pos(UpperCase('Unable to complete network request to host'),Uppercase(E.Message)) <> 0 then
          Messagedlg('Verifique o Firebird ou o arquivo de banco de dados!!.',mtInformation,[mbOK],0);
     End;
   End;
  Finally

  End;

end;

procedure TfrmConfBase.btnFecharClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

function TfrmConfbase.DadosdaRede(Path: String): TRede;
Var
  VTmp : String;
  I : Integer;
begin
   VTmp := Path;
   If Copy(Path,1,2) <> '\\' then
   Begin
     DadosDaRede.Maquina := '';
     DadosDaRede.Path := Path;
     exit;
   End;

   VTmp := StringReplace(VTmp, '\\','',[rfReplaceAll, rfIgnoreCase]);

   For I :=1 to Length(VTmp) do
   Begin
     If Copy(VTmp,I,1) = '\' then
     Begin
       DadosDaRede.Maquina := Copy(VTmp,1,I-1);
       Break;
     End;
   End;
   VTmp := Copy(VTmp,I+1,Length(VTmp));
   For I :=1 to Length(VTmp) do
   Begin
     If Copy(VTmp,I,1) = '\' then
     Begin
       DadosDaRede.Path := Copy(VTmp,1,I-1) + ':' + Copy(VTmp,I,Length(VTmp));
       Break;
     End;
   End;

end;

end.
