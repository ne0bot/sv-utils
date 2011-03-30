{*******************************************************}
{     SVButtonGroup                                     }
{                                                       }
{                                                       }
{       Copyright (C) 2011 "Linas Naginionis"           }
{     http://code.google.com/p/sv-utils/                }
{     Linas Naginionis lnaginionis@gmail.com            }
{*******************************************************}

unit uSVButtonGroup;

interface

uses
  Classes, Graphics, GraphUtil, ButtonGroup, Windows, CategoryButtons, Controls;

type
  TButtonGroupColorArray = array[0..9] of TColor;
  /// <summary>
  /// Class to hold custom colors for SVButtonGroups
  /// </summary>
  TButtonGroupColors = class(TPersistent)
  {.Z+}
  protected
    FUpdating: Boolean;
    FOnChange: TNotifyEvent;
    function GetColor(Index : Integer) : TColor;
    procedure SetColor(Index : Integer; Value : TColor);
    procedure DoOnChange;
  public
    FColors: TButtonGroupColorArray;

    procedure Assign(Source : TPersistent); override;
    procedure BeginUpdate;
    procedure EndUpdate;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  {.Z-}
  published
    property BackColor : TColor index 0  read  GetColor write SetColor;
    property ButtonColor: TColor index 1 read GetColor write SetColor;
    property ButtonColorFrom : TColor index 2 read  GetColor write SetColor;
    property ButtonColorTo : TColor index 3  read  GetColor write SetColor;
    property ButtonDownColor : TColor index 4 read GetColor write SetColor;
    property ButtonDownColorFrom : TColor index 5 read GetColor write SetColor;
    property ButtonDownColorTo : TColor index 6 read GetColor write SetColor;
    property HotButtonColor : TColor index 7 read  GetColor write SetColor;
    property HotButtonColorFrom : TColor index 8 read  GetColor write SetColor;
    property HotButtonColorTo : TColor index 9 read  GetColor write SetColor;
  end;
  /// <summary>
  /// SVButtonGroup main class
  /// </summary>
  TSVButtonGroup = class(ButtonGroup.TButtonGroup)
  private
    FColors: TButtonGroupColors;
    FButtonGradient: Boolean;
    FHTMLCaptions: Boolean;
    FButtonGradientDirection: TGradientDirection;
    FDrawFocusRect: Boolean;
    FHotTrack: Boolean;
    procedure SetButtonGradient(const Value: Boolean);
    procedure ColorsChange(Sender: TObject);
    procedure SetHTMLCaptions(const Value: Boolean);
    procedure SetButtonGradientDirection(const Value: TGradientDirection);
    procedure SetDrawFocusRect(const Value: Boolean);
  protected
    procedure DrawButton(Index: Integer; Canvas: TCanvas;
      Rect: TRect; State: TButtonDrawState); override;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
{$REGION 'Doc'}
      /// <summary>
      ///  ButtonGradient
      /// If true, uses From and To colors to draw gradient buttons
      /// </summary>
{$ENDREGION}
    property ButtonGradient: Boolean read FButtonGradient write SetButtonGradient default True;
    property ButtonGradientDirection: TGradientDirection
       read FButtonGradientDirection write SetButtonGradientDirection default gdVertical;
    property Colors: TButtonGroupColors read FColors write FColors;
    property DrawFocusRect: Boolean read FDrawFocusRect write SetDrawFocusRect default False;
    property HotTrack: Boolean read FHotTrack write FHotTrack default True;
{$REGION 'Doc'}
      /// <summary>
      ///  HTMLCaptions
      /// If True some simples html tags are supporetd while painting button captions
      ///  Supported tags:
      /// <B> - Bold e.g. <B>This is bold</B>
      /// <I> - Italic e.g. <I>This is italic</I>
      /// <U> - Underline e.g. <U>This is underlined</U>
      /// <S> - Strikeout e.g. <U>This is strikeout</S>
      /// <font-color=x> Font colour e.g.
      ///              <font-color=clRed>Delphi red</font-color>
      ///              <font-color=#FFFFFF>Web white</font-color>
      ///              <font-color=$000000>Hex black</font-color>
      /// <font-size=x> Font size e.g. <font-size=30>This is some big text</font-size>
      /// <font-family> Font family e.g. <font-family=Arial>This is arial</font-family>
      /// </summary>
{$ENDREGION}
    property HTMLCaptions: Boolean read FHTMLCaptions write SetHTMLCaptions default False;
  end;


procedure Register;

implementation


uses
  uVikButtonGroupUtils;

procedure Register;
begin
  RegisterComponents('Sound Vibe', [TSVButtonGroup]);
end;



{ TVikButtonGroup }

procedure TSVButtonGroup.ColorsChange(Sender: TObject);
begin
  Invalidate;
end;

constructor TSVButtonGroup.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColors := TButtonGroupColors.Create;
  FColors.OnChange := ColorsChange;
  //init default colors
  FColors.BackColor := clWindow;
  FColors.ButtonColor := clWindow;
  FColors.ButtonColorFrom := clWindow;
  FColors.ButtonColorTo := clWindow;
  FColors.HotButtonColor := clHotLight;
  FColors.HotButtonColorFrom := clHotLight;
  FColors.HotButtonColorTo := clHotLight;
  FColors.ButtonDownColor := clBtnFace;
  FColors.ButtonDownColorFrom := clBtnFace;
  FColors.ButtonDownColorTo := clBtnFace;
  FHotTrack := True;

  FHTMLCaptions := False;
  FButtonGradient := True;
  FDrawFocusRect := False;
  FButtonGradientDirection := gdVertical;
  ButtonOptions := ButtonOptions + [gboAllowReorder, gboFullSize, gboShowCaptions, gboGroupStyle];
end;

destructor TSVButtonGroup.Destroy;
begin
  FColors.Free;
  inherited Destroy;
end;

procedure TSVButtonGroup.DrawButton(Index: Integer; Canvas: TCanvas; Rect: TRect;
  State: TButtonDrawState);
var
  TextLeft, TextTop, RectHeight, ImgTop, TextOffset: Integer;
  ButtonItem: TGrpButtonItem;
  FillColor, EdgeColor: TColor;
  InsertIndication, TextRect, OrgRect: TRect;
  Text: string;
  bWasFilled: Boolean;
  OldBrushStyle: TBrushStyle;
begin
  if Assigned(OnDrawButton) and (not (csDesigning in ComponentState)) then
    OnDrawButton(Self, Index, Canvas, Rect, State)
  else
  begin
    OrgRect := Rect;
    bWasFilled := False;

    Canvas.Font := Self.Font;
    if (bdsDown in State) or (bdsSelected in State) then
    begin
      if FButtonGradient then
      begin
        GradientFillCanvas(Canvas, FColors.ButtonDownColorFrom, FColors.ButtonDownColorTo, OrgRect,
          FButtonGradientDirection);
        bWasFilled := True;
      end
      else
      begin
        Canvas.Brush.Color := FColors.ButtonDownColor;
       // Canvas.Font.Color := clBtnFace;
      end;

    end
    else
    begin
      if FButtonGradient then
      begin
        GradientFillCanvas(Canvas, FColors.ButtonColorFrom, FColors.ButtonColorTo, OrgRect,
          FButtonGradientDirection);
        bWasFilled := True;
      end
      else
        Canvas.Brush.Color := FColors.ButtonColor;
    end;

    FillColor := Canvas.Brush.Color;
    EdgeColor := GetShadowColor(FillColor, -25);

    if not bWasFilled then
      Canvas.FillRect(Rect);

    InflateRect(Rect, -2, -1);

    ButtonItem := Self.Items[Index];

    if (bdsHot in State) and not (bdsDown in State) and (FHotTrack) then
    begin
      EdgeColor := GetShadowColor(EdgeColor, -50);
      { Draw the edge outline }
      if FButtonGradient then
      begin
        GradientFillCanvas(Canvas, FColors.HotButtonColorFrom, FColors.HotButtonColorTo, Rect,
          FButtonGradientDirection);
      end
      else
      begin
        Canvas.Brush.Color := FColors.HotButtonColor;
        Canvas.FillRect(Rect);
      end;
     // Canvas.Brush.Color := EdgeColor;
     // Canvas.FrameRect(Rect);
    //  TButtonGroup(Sender).Cursor := crHandPoint;
    end
    else
    begin
      Canvas.Brush.Color := FillColor;
     // TButtonGroup(Sender).Cursor := crDefault;
    end;

    { Compute the text location }
    TextLeft := Rect.Left + 4;
    RectHeight := Rect.Bottom - Rect.Top;
     TextTop := Rect.Top + (RectHeight - Canvas.TextHeight('Wg')) div 2; { Do not localize }
    if TextTop < Rect.Top then
      TextTop := Rect.Top;
    if bdsDown in State then
    begin
      Inc(TextTop);
      Inc(TextLeft);
    end;

    { Draw the icon - prefer the event }
    TextOffset := 0;
    if Assigned(OnDrawIcon) then
      OnDrawIcon(Self, Index, Canvas, OrgRect, State, TextOffset)
    else if (Self.Images <> nil) and (ButtonItem.ImageIndex > -1) and
        (ButtonItem.ImageIndex < Self.Images.Count) then
    begin
      ImgTop := Rect.Top + (RectHeight - Self.Images.Height) div 2;
      if ImgTop < Rect.Top then
        ImgTop := Rect.Top;
      if bdsDown in State then
        Inc(ImgTop);
      Self.Images.Draw(Canvas, TextLeft - 1, ImgTop, ButtonItem.ImageIndex);
      TextOffset := Self.Images.Width + 1;
    end;

    { Show insert indications }
    if [bdsInsertLeft, bdsInsertTop, bdsInsertRight, bdsInsertBottom] * State <> [] then
    begin
      Canvas.Brush.Color := GetShadowColor(EdgeColor);
      InsertIndication := Rect;
      if bdsInsertLeft in State then
      begin
        Dec(InsertIndication.Left, 2);
        InsertIndication.Right := InsertIndication.Left + 2;
      end
      else if bdsInsertTop in State then
      begin
        Dec(InsertIndication.Top);
        InsertIndication.Bottom := InsertIndication.Top + 2;
      end
      else if bdsInsertRight in State then
      begin
        Inc(InsertIndication.Right, 2);
        InsertIndication.Left := InsertIndication.Right - 2;
      end
      else if bdsInsertBottom in State then
      begin
        Inc(InsertIndication.Bottom);
        InsertIndication.Top := InsertIndication.Bottom - 2;
      end;
      Canvas.FillRect(InsertIndication);
      Canvas.Brush.Color := FillColor;
    end;

    if gboShowCaptions in Self.ButtonOptions then
    begin
      { Avoid clipping the image }
      Inc(TextLeft, TextOffset);
      TextRect.Left := TextLeft;
      TextRect.Right := Rect.Right - 1;
      TextRect.Top := TextTop;
      TextRect.Bottom := Rect.Bottom -1;
      Text := ButtonItem.Caption;

      OldBrushStyle := Canvas.Brush.Style;
      Canvas.Brush.Style := bsClear;

      if FHTMLCaptions then
        DrawHTML(TextRect, Canvas, Text, [vdfEndEllipsis])
      else
        Canvas.TextRect(TextRect, Text, [tfEndEllipsis]);
    end;

    if bdsFocused in State then
    begin
      { Draw the focus rect }
      if FDrawFocusRect then
      begin
        Canvas.Brush.Style := bsSolid;
        InflateRect(Rect, -2, -2);
        Canvas.DrawFocusRect(Rect);
      end;
    end;

    Canvas.Brush.Style := OldBrushStyle;

    if Assigned(OnAfterDrawButton) then
      OnAfterDrawButton(Self, Index, Canvas, OrgRect, State);

    Canvas.Brush.Color := FColors.BackColor; { Restore the original color }
  end;
end;

procedure TSVButtonGroup.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  ix: Integer;
begin
  inherited;
  ix := Self.IndexOfButtonAt(X,Y);
  if ix > -1 then
  begin
    if FHotTrack then
    begin
      Self.Cursor := crHandPoint;
    end
    else
    begin
      Self.Cursor := crDefault;
    end;
  end
  else
  begin
    Self.Cursor := crDefault;
  end;
end;

procedure TSVButtonGroup.SetButtonGradient(const Value: Boolean);
begin
  if Value <> FButtonGradient then
  begin
    FButtonGradient := Value;
    Invalidate;
  end;
end;


procedure TSVButtonGroup.SetButtonGradientDirection(const Value: TGradientDirection);
begin
  if Value <> FButtonGradientDirection then
  begin
    FButtonGradientDirection := Value;
    Invalidate;
  end;
end;

procedure TSVButtonGroup.SetDrawFocusRect(const Value: Boolean);
begin
  if FDrawFocusRect <> Value then
  begin
    FDrawFocusRect := Value;
    Invalidate;
  end;
end;

procedure TSVButtonGroup.SetHTMLCaptions(const Value: Boolean);
begin
  if Value <> FHTMLCaptions then
  begin
    FHTMLCaptions := Value;
    Invalidate;
  end;

end;

{ TButtonGroupColors }

procedure TButtonGroupColors.Assign(Source: TPersistent);
begin
  if Source is TButtonGroupColors then
  begin
    FColors := TButtonGroupColors(Source).FColors;
    FOnChange := TButtonGroupColors(Source).FOnChange;
  end
  else
    inherited Assign(Source);
end;

procedure TButtonGroupColors.BeginUpdate;
begin
  FUpdating := True;
end;

procedure TButtonGroupColors.DoOnChange;
begin
  if not FUpdating and Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TButtonGroupColors.EndUpdate;
begin
  FUpdating := False;
  DoOnChange;
end;

function TButtonGroupColors.GetColor(Index: Integer): TColor;
begin
  Result := FColors[Index];
end;

procedure TButtonGroupColors.SetColor(Index: Integer; Value: TColor);
begin
  if Value <> FColors[Index] then
  begin
    FColors[Index] := Value;
    DoOnChange;
  end;
end;

end.
