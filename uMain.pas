unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,

  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.Helpers,
  System.Messaging,
  Androidapi.JNI.App,
  Androidapi.JNI.JavaTypes;

type
  TFormMain = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Text1: TText;
    procedure Button1Click(Sender: TObject);
  private
    var FRequestCode: Integer;
    procedure HandleActivityMessage(const Sender: TObject; const M: TMessage);
    function OnActivityResult(RequestCode, ResultCode: Integer; Data: JIntent): Boolean;
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

procedure TFormMain.Button1Click(Sender: TObject);
var
  LValor: Integer;
  LIntent: JIntent;
begin
  // Inscreva-se para receber a notificação de resultado da atividade
  TMessageManager.DefaultManager.SubscribeToMessage(TMessageResultNotification, HandleActivityMessage);

  LIntent := TJIntent.Create;
  LIntent.SetAction(StringToJString('br.com.execucao.PAGAR'));

  // Adiciona o valor da transação como um extra
  LIntent.putExtra(StringToJString('VALOR_TRANSACAO'), 2500);

  // Adiciona o tipo de transação como um extra
  LIntent.putExtra(StringToJString('TRANSACAO'), StringToJString('CREDITO'));

  // Inicia a atividade com resultado
  TAndroidHelper.Activity.startActivityForResult(LIntent, FRequestCode);
end;

procedure TFormMain.HandleActivityMessage(const Sender: TObject; const M: TMessage);
begin
  if M is TMessageResultNotification then
  begin
    OnActivityResult(TMessageResultNotification(M).RequestCode, TMessageResultNotification(M).ResultCode,  TMessageResultNotification(M).Value);
  end;
end;

function TFormMain.OnActivityResult(RequestCode, ResultCode: Integer; Data: JIntent): Boolean;
var
  ValorTransacao: Integer;
  TipoTransacao: JString;
  Serial: JString;
  Bandeira: JString;
  NumCartao: JString;
  Autorizacao: JString;
  Nsu: JString;
  CnpjAdquirente: JString;
  NomeAdquirente: JString;
  Comprovante: JString;
  Erro: JString;
begin
  Result := False;
  TMessageManager.DefaultManager.Unsubscribe(TMessageResultNotification, HandleActivityMessage);

  if RequestCode = FRequestCode then
  begin
    if ResultCode = TJActivity.JavaClass.RESULT_OK then
    begin
      // Recupera o valor da transação
      ValorTransacao := Data.getIntExtra(StringToJString('VALOR_TRANSACAO'), 0);

      // Recupera o tipo de transação
      TipoTransacao := Data.getStringExtra(StringToJString('TRANSACAO'));

      // Recupera outros valores
      Serial := Data.getStringExtra(StringToJString('SERIAL'));
      Bandeira := Data.getStringExtra(StringToJString('BANDEIRA'));
      NumCartao := Data.getStringExtra(StringToJString('NUMCARTAO'));
      Autorizacao := Data.getStringExtra(StringToJString('AUTORIZACAO'));
      Nsu := Data.getStringExtra(StringToJString('NSU'));
      CnpjAdquirente := Data.getStringExtra(StringToJString('CNPJ_ADQUIRENTE'));
      NomeAdquirente := Data.getStringExtra(StringToJString('NOME_ADQUIRENTE'));
      Comprovante := Data.getStringExtra(StringToJString('COMPROVANTE'));
      Erro := Data.getStringExtra(StringToJString('ERRO'));

      // Agora você pode usar os valores recuperados como necessário
      Memo1.Lines.Add('Valor da transação: ' + IntToStr(ValorTransacao));
      Memo1.Lines.Add('Tipo de transação: ' + JStringToString(TipoTransacao));
      Memo1.Lines.Add('Serial: ' + JStringToString(Serial));
      Memo1.Lines.Add('Bandeira: ' + JStringToString(Bandeira));
      Memo1.Lines.Add('Número do Cartão: ' + JStringToString(NumCartao));
      Memo1.Lines.Add('Autorização: ' + JStringToString(Autorizacao));
      Memo1.Lines.Add('NSU: ' + JStringToString(Nsu));
      Memo1.Lines.Add('CNPJ da Adquirente: ' + JStringToString(CnpjAdquirente));
      Memo1.Lines.Add('Nome da Adquirente: ' + JStringToString(NomeAdquirente));
      Memo1.Lines.Add('Comprovante: ' + JStringToString(Comprovante));
      Memo1.Lines.Add('Erro: ' + JStringToString(Erro));
    end;
  end;
end;


end.
