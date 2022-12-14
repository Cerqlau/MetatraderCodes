//+------------------------------------------------------------------+
//|                                               MadRabbit_MACD.mq5 |
//|              Lauro Cerqueira Copyright 2020, MAD RABBIT LAB Inc. |
//|                    https://www.mql5.com/pt/users/laurorcerqueira |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Controls\Defines.mqh>
#undef CONTROLS_FONT_NAME 
#undef CONTROLS_FONT_SIZE 

#undef CONTROLS_BUTTON_COLOR
#undef CONTROLS_BUTTON_COLOR_BG
#undef CONTROLS_BUTTON_COLOR_BORDER

#undef CONTROLS_DIALOG_COLOR_BORDER_LIGHT
#undef CONTROLS_DIALOG_COLOR_BORDER_DARK
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BORDER 

input string   font_name                  = "Trebuchet MS";
input int      font_size                  = 10;

input color    button_color               = C'0x3B,0x29,0x28';
input color    button_color_bg            = C'0xDD,0xE2,0xEB';
input color    button_color_border        = C'0xB2,0xC3,0xCF';

input color    dialog_color_border_light  = White;
input color    dialog_color_border_dark   = C'0xB6,0xB6,0xB6';
input color    dialog_color_bg            = C'0xF0,0xF0,0xF0';
input color    dialog_color_caption_text  = C'0x28,0x29,0x3B';
input color    dialog_color_client_bg     = C'0xF7,0xF7,0xF7';
input color    dialog_color_client_border = C'0xC8,0xC8,0xC8';

#define CONTROLS_FONT_NAME                font_name
#define CONTROLS_FONT_SIZE                font_size

#define CONTROLS_BUTTON_COLOR             button_color
#define CONTROLS_BUTTON_COLOR_BG          button_color_bg
#define CONTROLS_BUTTON_COLOR_BORDER      button_color_border

#define CONTROLS_DIALOG_COLOR_BORDER_LIGHT dialog_color_border_light
#define CONTROLS_DIALOG_COLOR_BORDER_DARK dialog_color_border_dark
#define CONTROLS_DIALOG_COLOR_BG          dialog_color_bg
#define CONTROLS_DIALOG_COLOR_CAPTION_TEXT dialog_color_caption_text
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   dialog_color_client_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BORDER dialog_color_client_border

#include <Controls\Dialog.mqh>
#include <Controls\BmpButton.mqh>

CAppDialog AppWindow;
//+------------------------------------------------------------------+
//| Função de inicialização do Expert                                |
//+------------------------------------------------------------------+
int OnInit()
  {
//---Cria o diálogo do aplicativo
   if(!AppWindow.Create(0,"MadRabbit_Universal",0,10,10,400,300))
      return(INIT_FAILED);
//---Execução da aplicação
   AppWindow.Run();
//--- sucesso
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Função de desinicialização do Expert                             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destrói o diálogo
   AppWindow.Destroy(reason);
  }
//+------------------------------------------------------------------+
//| Função de evento do gráfico do Expert                            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // ID do evento  
                  const long& lparam,   // parâmetro do evento do tipo long
                  const double& dparam, // parâmetro do evento do tipo double
                  const string& sparam) // parâmetro do evento do tipo string
  {
   AppWindow.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+