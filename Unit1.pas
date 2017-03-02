unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.DateUtils,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ScrollBox,
  FMX.Memo, FMX.Controls.Presentation, FMX.StdCtrls;

type

  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    GroupBox1: TGroupBox;
    rbServal: TRadioButton;
    rbFennec: TRadioButton;
    Button2: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { private 宣言 }
  public
    { public 宣言 }
    procedure show(str: String);
  end;

type
  // TKemonoクラス定義
  TKemono = class(TObject) // TServel, TFennectの親クラス
  public
    function Voice: string; virtual;
    // Voice 文字列を返すメソッド。実装は子に任せる virtual; abstract キーワードをつけている
  end;

  TFriends = class of TKemono; // TKemonoクラスの型を表す[TFriends]を定義

  TServal = class(TKemono) // TKemonoを継承
  public
    function Voice: string; override;
    // 親クラス内のVoice 文字列を返すメソッド abstractのVoiceメソッド overrideするキーワード付き
  end;

  TFennec = class(TKemono) // TKemonoを継承
  public
    function Voice: string; override;
    // 親クラス内のVoice 文字列を返すメソッド abstractのVoiceメソッド overrideするキーワード付き
  end;

  // TDateというクラス定義識別子を、「 = class 」としてクラス定義
type
  TDate = class // 親となるTDateクラス
  private // 他ユニットからは参照できず、アクセスもできない
    FDate: TDateTime; // クラスで保持するデータ（フィールド）の定義
  public // 他ユニットから参照、アクセス可能
    constructor Create; overload; // デフォルトのCreateと同じ記述でoverload指定
    constructor Create(Y, M, D: Integer); overload; // 初期値を与えるCreateのoverload
    procedure SetValue(Y, M, D: Integer); overload; // 年月日をIntegerでセットするメソッド
    procedure SetValue(NewDate: TDateTime); overload; // 年月日をTDateTimeでセットするメソッド
    function LeapYear: Boolean; // うるう年かチェックするメソッド
    function GetText: string;
    // フィールドにアクセスできないので、日付を文字列で取得する関数
    procedure Increase(NumberOfDays: Integer = 1);
    procedure Decrease(NumberOfDays: Integer = 1);
  end; // クラス定義もend;で締める

  // TPersonのクラス定義
  TPerson = class(TObject) // 新たにTPersonクラスを定義
  private
    FName: string;
    FBirthDate: TDate; // 以前に定義した日付情報をもつTDateクラスをフィールドとして使用
  public
    constructor Create(name: string); // コンストラクター Create の宣言
    destructor Destroy; override; // デストラクタ Destroyの宣言 + override
    function info: string;
  end; // クラス定義end;

  // TDateクラス継承したTNewDateのクラス定義
  TNewDate = class(TDate) // TDateから派生（TDateを継承）する 子クラス（サブクラス）
  public
    function GetText: string; // 親の持つ GetTextメソッドをTNewDateクラス版に書き換えるための宣言
  end;

 //メタクラスを使う （クラスの型名を扱える型・クラス参照）
  function KemonoVoice(KemonoClassName: TFriends): String;
var
  Form1: TForm1;

implementation

{$R *.fmx}

{ TForm1 }
procedure TForm1.Button1Click(Sender: TObject);
var
  myDay: TDate; // 親クラスのオブジェクト識別子
  myNewDay: TNewDate; // 子クラスのオブジェクト識別子
  myObject: TObject;
begin

  if Sender is TButton then
    show(TButton(Sender).Text);

  myDay := TDate.Create; // 親オブジェクトのCreate
  myObject := myDay;
  myNewDay := TNewDate.Create; // 子オブジェクトのCreate

  try // tryで例外発生の検知をセット
    show('親クラス: ' + myDay.GetText); // 親オブジェクトのGetTextメソッドで文字列を取得して表示
    show('子クラス: ' + myNewDay.GetText); // 子オブジェクトのGetTextメソッドで文字列を取得して表示

    if (myObject as TDate).LeapYear then
      show('うるうどしです')
    else
      show('うるうどしではありません');

  finally // try以降で例外が発生してもしなくても 必ず実行する処理を finally – end; に記述
    myDay.Free; // 親オブジェクトの解放
    myNewDay.Free; // 子オブジェクトの解放
  end; // finally のブロックはend; で閉じる

end;

procedure TForm1.Button2Click(Sender: TObject);
var
  myAnimal: TKemono; // 親クラスのオブジェクト識別子を宣言
begin
  if rbServal.IsChecked then
  // 選ばれているチェックボックスによって TServalかTFennecクラスのどちらかをCreate
  begin
    myAnimal := TServal.Create; // TServalのオブジェクトを親の方のオブジェクト識別子に代入
  end
  else
  begin
    myAnimal := TFennec.Create; // TFennecのオブジェクトを親の方のオブジェクト識別子に代入
  end;
  try
    show(myAnimal.Voice); // 親の型のオブジェクト識別子に子のクラスのオブジェクト参照が代入されている
    // 親のオブジェクト識別子を使っていても子のメソッドを呼び出せるのは、親クラスでVoiceがvirtual で定義されているから
  finally
    myAnimal.Free; // 解放
  end;
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
// チュートリアルシリーズでは紹介していない
// TButtonクラスを動的に作成して親コントロール（フォーム）にくっつける方法
var
  btn: TButton;
begin
  btn := TButton.Create(Self); // Self <=自分、つまりフォームを親としてTButtonのインスタンスを作成
  btn.Parent := Self; // Parentにフォームの参照を設定
  btn.Position.X := X; // X,Yの値を、マウスのクリック位置と同じ値に
  btn.Position.Y := Y;
  btn.Height := 35; // ボタンの高さと幅設定
  btn.Width := 135;
  btn.Text := Format('@ %d, %d', [Round(X), Round(Y)]); // ボタンの表示にXY座標の文字列を入れておく
end;

procedure TForm1.show(str: String);
begin
  Memo1.Lines.add(str);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if rbServal.IsChecked then
    show(KemonoVoice(TServal))
  else
    show(KemonoVoice(TFennec));
end;

{ TDate }

constructor TDate.Create; // 実装部にはOverloadキーワードを記述不要
begin
  inherited; // メソッド名もパラメータも同じであれば inherited の後ろのパラメータは省略可能
  FDate := Date; // 初期値としてDateで今日の日付を代入
end;

constructor TDate.Create(Y, M, D: Integer); // 初期値有のCreate.実装部にはOverloadキーワード不要
begin
  inherited Create;
  { パラメータが親クラスのCreateと異なるので、省略できず、inheritedの後ろにCreateを記述して親の。Createを実行することを明記している }
  FDate := EncodeDate(Y, M, D);
end;

procedure TDate.Decrease(NumberOfDays: Integer = 1);
begin
  FDate := FDate - NumberOfDays;
end;

function TDate.GetText: string;
begin
  Result := DateToStr(FDate);
  // 親の実装 ： ’2017/03/06’の文字列が返る

end;

procedure TDate.Increase(NumberOfDays: Integer = 1);
begin
  FDate := FDate + NumberOfDays
end;

function TDate.LeapYear: Boolean;
begin
  Result := IsLeapYear(YearOf(FDate));
end;

procedure TDate.SetValue(NewDate: TDateTime);
// TDateTime型のパラメータの時実行.実装部にはoverloadキーワード不要
begin
  FDate := NewDate;
end;

procedure TDate.SetValue(Y, M, D: Integer);
// Integerx3の時実行.実装部にはoverloadキーワード不要
begin
  FDate := EncodeDate(Y, M, D);
  // 指定されたパラメータをTDateTime型に変換してFDateフィールドに代入
end;

{ TPerson }

constructor TPerson.Create(name: string); // コンストラクター Create の実装
begin
  inherited Create;
  FName := name; // Create時の初期値としてフィールドに代入
  FBirthDate := TDate.Create; // フィールドに使用しているTDate型のクラスの確保
end;

destructor TPerson.Destroy; // デストラクタ Destroyの宣言 (実装部に override キーワードは不要）
begin
  FBirthDate.Free; // Create時に確保したFBirthDateの破棄
  inherited;
end;

function TPerson.info: string;
begin
  Result := FName + ': ' + FBirthDate.GetText;
end;

{ TNewDate }

function TNewDate.GetText: string;
begin
  Result := FormatDateTime('ggE年m月d日 (dddd)', FDate);
  // 子の実装 ’平成29年3月6日 (月曜日)’の文字列が返る
end;

{ TServal }

function TServal.Voice: string;
begin
  Result := 'meow';
end;

{ TFennec }

function TFennec.Voice: string;
begin
  Result := 'yelp';
end;

{ TKemono }

function TKemono.Voice: string;
begin
  Result := '動物の鳴き声';
end;

{ クラス外 }
function KemonoVoice(KemonoClassName: TFriends): String;
var
  myAnimal: TKemono;
begin
  myAnimal := KemonoClassName.Create;
  try
    Result := myAnimal.Voice;
  finally
    myAnimal.Free;
  end;
end;

end.
