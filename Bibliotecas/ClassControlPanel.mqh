//+------------------------------------------------------------------+
//|                                           ClassControlPainel.mqh |
//|                                            Rafael Floriani Pinto |
//|                           https://www.mql5.com/pt/users/rafaelfp |
//+------------------------------------------------------------------+
#property copyright "Rafael Floriani Pinto"
#property link      "https://www.mql5.com/pt/users/rafaelfp"
#ifndef ClassControlPainelV1rafaelfp
#define ClassControlPainelV1rafaelfp
#define OBJMARGIMX 0.20
#define OBJMARGIMY 0.06
#define OBJGERALNAME "GERAL"
enum ENUM_PANEL_INTEGER
  {
   PANEL_BGCOLOR,
   PANEL_BORDERCOLOR,
   PANEL_BORDERTYPE,
   PANEL_CORNERPOSITION
  };

enum ENUM_BUTTON_INTEGER
  {
   BUTTON_BGCOLOR,
   BUTTON_BORDERCOLOR,
   BUTTON_BORDERTYPE,
   BUTTON_FONTSIZE,
   BUTTON_FONTCOLOR
  };
enum ENUM_BUTTON_STRING
  {
   BUTTON_TEXTSHOW
  };
enum ENUM_TEXT_INTEGER
  {
   TEXT_FONTSIZE,
   TEXT_FONTCOLOR,
   TEXT_READONLY
  };
enum ENUM_TEXT_STRING
  {
   TEXT_TEXTSHOW
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CControlPainel
  {
public:
                     CControlPainel(long=0,double=0.25,double=0.25,long=5,long=5,ENUM_BASE_CORNER=CORNER_LEFT_LOWER,string="Panelrafaelfp");
   bool              CreatePanel();
   void              DeletePanel();
   bool              CreateButton(const string,color,color,color,ENUM_BORDER_TYPE);
   bool              CreateText(const string,color,int,bool=true);
   bool              ButtonGetState(int);
   void              ButtonSetState(int,bool=false);
   string            TextGetString(int);
   void              PanelModifyInteger(ENUM_PANEL_INTEGER,long);
   void              ButtonModifyInteger(int,ENUM_BUTTON_INTEGER,long);
   void              ButtonModifyString(int,ENUM_BUTTON_STRING,const string);
   void              TextModifyInteger(int,ENUM_TEXT_INTEGER,long);
   void              TextModifyString(int,ENUM_TEXT_STRING,const string);
   void              PanelSetFont(const string);

private:
   //CONSTS
   const long        ID;
   //VARS
   double            PropWidth;
   double            PropHeight;
   int               ChartWidth;
   int               ChartHeight;
   long              XMargim;
   long              YMargim;
   string            FontName;
   //PANEL STATUS
   string            PanelName;
   long              PanelWidth;
   long              PanelHeight;
   ENUM_BASE_CORNER  PanelCorner;
   color             PanelBGColor;
   color             PanelBorderColor;
   ENUM_BORDER_TYPE  PanelBorder;
   //OBJ DIMENSIONS
   int               NumbersObjects;
   int               NumberButtons[];
   int               NumberTexts[];
   long              ObjXSize;
   long              ObjYSize;
   long              ObjXMargim;
   long              ObjYMargim;
   long              ObjAddYMargim;
   //FUNCS
   long              SetXDistance(ENUM_BASE_CORNER,long,long);
   long              SetYDistance(ENUM_BASE_CORNER,long,long);
   bool              ChangePanelAppearence();
   void              SetObjectYDimensions();
   void              SetObjectXDimensions();
   long              SetYMargimObj(int);
   void              SetObjectsPlace();
   string            GetGeralName(const string,int)const;
  };




//+------------------------------------------------------------------+
//|CONSTRUCTOR                                                       |
//+------------------------------------------------------------------+
CControlPainel::CControlPainel(long Chart_ID=0,double PropWidthGraf=0.250000,double PropHeightGraf=0.250000,
                               long XMARGIM=5,long YMARGIM=5,ENUM_BASE_CORNER ObjCorner=CORNER_LEFT_LOWER,string PANELNAME="Panelrafaelfp")
   :ID(Chart_ID),
    PropWidth(PropWidthGraf>0 && PropWidthGraf<1  ? PropWidthGraf :0.25),
    PropHeight(PropHeightGraf>0 && PropHeightGraf<1? PropHeightGraf :0.25),
    PanelCorner(ObjCorner),
    PanelName(PANELNAME),
    ChartWidth((int)ChartGetInteger(ID,CHART_WIDTH_IN_PIXELS,0)),
    ChartHeight((int)ChartGetInteger(ID,CHART_HEIGHT_IN_PIXELS,0)),
    XMargim(XMARGIM>0?XMARGIM:5),
    YMargim(YMARGIM>0?YMARGIM:5),
    PanelBGColor(clrBlack),
    PanelBorderColor(clrWhite),
    PanelBorder(BORDER_RAISED),
    NumbersObjects(0),
    FontName("Times New Roman")
  {

  }
//+------------------------------------------------------------------+
//|PUBLIC DEFINITIONS                                                |
//+------------------------------------------------------------------+
bool CControlPainel::CreatePanel()
  {


   if(!ObjectCreate(ID,PanelName,OBJ_RECTANGLE_LABEL,0,0,0))
     {
      return false;
     }
   if(!ObjectSetInteger(ID,PanelName,OBJPROP_CORNER,PanelCorner))
     {
      return false;
     }
   PanelWidth=(long)(PropWidth*ChartWidth);
   if(!ObjectSetInteger(ID,PanelName,OBJPROP_XSIZE,PanelWidth))
     {
      return false;
     }
   if(!ObjectSetInteger(ID,PanelName,OBJPROP_XDISTANCE,SetXDistance(PanelCorner,XMargim,PanelWidth)))
     {
      return false;
     }
   PanelHeight=(long)(PropHeight*ChartHeight);
   if(!ObjectSetInteger(ID,PanelName,OBJPROP_YSIZE,PanelHeight))
     {
      return false;
     }
   if(!ObjectSetInteger(ID,PanelName,OBJPROP_YDISTANCE,SetYDistance(PanelCorner,YMargim,PanelHeight)))
     {
      return false;
     }
   if(!ChangePanelAppearence())
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlPainel::DeletePanel(void)
  {
   ObjectDelete(ID,PanelName);
   for(int i=1; i<=NumbersObjects; i++)
     {
      ObjectDelete(ID,GetGeralName(OBJGERALNAME,i));
     }
   NumbersObjects=0;
   ArrayFree(NumberButtons);
   ArrayFree(NumberTexts);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlPainel::CreateButton(const string BntText="Bnt",color FontColor=clrWhite,color BntBGColor=clrRed,
                                  color BntBorderColor=clrWhite,ENUM_BORDER_TYPE BntBorder=BORDER_RAISED)
  {
   NumbersObjects++;
   int N=ArraySize(NumberButtons);
   ArrayResize(NumberButtons,N+1);
   NumberButtons[N]=NumbersObjects;
   string BntName=GetGeralName(OBJGERALNAME,NumbersObjects);
   if(!ObjectCreate(ID,BntName,OBJ_BUTTON,0,0,0))
     {
      ArrayResize(NumberButtons,N);
      NumbersObjects--;
      return false;
     }
   SetObjectsPlace();
   if(!ObjectSetInteger(ID,BntName,OBJPROP_BGCOLOR,BntBGColor) || !ObjectSetInteger(ID,BntName,OBJPROP_BORDER_TYPE,BntBorder) ||
      !ObjectSetInteger(ID,BntName,OBJPROP_BORDER_COLOR,BntBorderColor)|| !ObjectSetInteger(ID,BntName,OBJPROP_COLOR,FontColor) ||
      !ObjectSetString(ID,BntName,OBJPROP_TEXT,BntText) || !ObjectSetInteger(ID,BntName,OBJPROP_READONLY,true))
     {
      ArrayResize(NumberButtons,N);
      NumbersObjects--;
      SetObjectsPlace();
      return false;
     }




   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlPainel::CreateText(const string TextT="Text",color FontColor=clrWhite,int TextFontSize=10,bool ReadOnly=true)
  {
   NumbersObjects++;
   int N=ArraySize(NumberTexts);
   ArrayResize(NumberTexts,N+1);
   NumberTexts[N]=NumbersObjects;
   string TextName=GetGeralName(OBJGERALNAME,NumbersObjects);
   if(!ObjectCreate(ID,TextName,OBJ_EDIT,0,0,0))
     {
      ArrayResize(NumberTexts,N);
      NumbersObjects--;
      return false;
     }
   SetObjectsPlace();
   if(!ObjectSetInteger(ID,TextName,OBJPROP_BGCOLOR,PanelBGColor) || !ObjectSetInteger(ID,TextName,OBJPROP_BORDER_TYPE,BORDER_FLAT) ||
      !ObjectSetInteger(ID,TextName,OBJPROP_BORDER_COLOR,PanelBGColor)|| !ObjectSetInteger(ID,TextName,OBJPROP_COLOR,FontColor) ||
      !ObjectSetString(ID,TextName,OBJPROP_TEXT,TextT) || !ObjectSetInteger(ID,TextName,OBJPROP_READONLY,ReadOnly)
      ||  !ObjectSetInteger(ID,TextName,OBJPROP_ALIGN,ALIGN_CENTER)  ||  !ObjectSetInteger(ID,TextName,OBJPROP_FONTSIZE,TextFontSize))
     {
      ArrayResize(NumberTexts,N);
      NumbersObjects--;
      SetObjectsPlace();
      return false;
     }





   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlPainel::ButtonGetState(int WhatBnt)
  {
   int N=ArraySize(NumberButtons);
   if(WhatBnt<=0 || WhatBnt>N)
      return false;
   string Name=GetGeralName(OBJGERALNAME,NumberButtons[WhatBnt-1]);
   return (bool)ObjectGetInteger(ID,Name,OBJPROP_STATE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlPainel::ButtonSetState(int WhatBnt,bool State=false)
  {
   int N=ArraySize(NumberButtons);
   if(WhatBnt<=0 || WhatBnt>N)
      return;
   string Name=GetGeralName(OBJGERALNAME,NumberButtons[WhatBnt-1]);
   ObjectSetInteger(ID,Name,OBJPROP_STATE,State);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CControlPainel::TextGetString(int WhatTxt)
  {
   int N=ArraySize(NumberTexts);
   if(WhatTxt<=0 || WhatTxt>N)
      return NULL;
   string Name=GetGeralName(OBJGERALNAME,NumberTexts[WhatTxt-1]);
   return ObjectGetString(ID,Name,OBJPROP_TEXT);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlPainel::PanelModifyInteger(ENUM_PANEL_INTEGER PropertId,long Val)
  {
   switch(PropertId)
     {
      case PANEL_BGCOLOR:
         if(ObjectSetInteger(ID,PanelName,OBJPROP_BGCOLOR,Val))
           {
            PanelBGColor=(color)Val;
            for(int i=1; i<=ArraySize(NumberTexts); i++)
              {
               ObjectSetInteger(ID,GetGeralName(OBJGERALNAME,NumberTexts[i-1]),OBJPROP_BGCOLOR,PanelBGColor);
               ObjectSetInteger(ID,GetGeralName(OBJGERALNAME,NumberTexts[i-1]),OBJPROP_BORDER_COLOR,PanelBGColor);
              }
           }
         return;
      case PANEL_BORDERCOLOR:
         if(ObjectSetInteger(ID,PanelName,OBJPROP_BORDER_COLOR,Val))
           {
            PanelBorderColor=(color)Val;
           }
         return;
      case PANEL_BORDERTYPE:
         if(ObjectSetInteger(ID,PanelName,OBJPROP_BORDER_TYPE,Val))
           {
            PanelBorder=(ENUM_BORDER_TYPE)Val;
           }
         return;
      case PANEL_CORNERPOSITION:
         if(ObjectSetInteger(ID,PanelName,OBJPROP_CORNER,Val))
           {
            PanelCorner=(ENUM_BASE_CORNER)Val;
            ObjectSetInteger(ID,PanelName,OBJPROP_XDISTANCE,SetXDistance(PanelCorner,XMargim,PanelWidth));
            ObjectSetInteger(ID,PanelName,OBJPROP_YDISTANCE,SetYDistance(PanelCorner,YMargim,PanelHeight));
            SetObjectsPlace();
           }
      default:
         return;
     };

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlPainel::ButtonModifyInteger(int WhatBnt,ENUM_BUTTON_INTEGER PropertID,long Val)
  {
   int N=ArraySize(NumberButtons);
   if(WhatBnt<=0 || WhatBnt>N)
      return;
   string Name=GetGeralName(OBJGERALNAME,NumberButtons[WhatBnt-1]);
   switch(PropertID)
     {
      case BUTTON_BGCOLOR:
         ObjectSetInteger(ID,Name,OBJPROP_BGCOLOR,Val);
         return;
      case BUTTON_BORDERCOLOR:
         ObjectSetInteger(ID,Name,OBJPROP_BORDER_COLOR,Val);
         return;
      case BUTTON_BORDERTYPE:
         ObjectSetInteger(ID,Name,OBJPROP_BORDER_TYPE,Val);
         return;
      case BUTTON_FONTCOLOR:
         ObjectSetInteger(ID,Name,OBJPROP_COLOR,Val);
         return;
      case BUTTON_FONTSIZE:
         ObjectSetInteger(ID,Name,OBJPROP_FONTSIZE,Val);
         return;
      default:
         return;
     };

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlPainel::ButtonModifyString(int WhatBnt,ENUM_BUTTON_STRING PropertID,const string Text)
  {
   int N=ArraySize(NumberButtons);
   if(WhatBnt<=0 || WhatBnt>N)
      return;
   string Name=GetGeralName(OBJGERALNAME,NumberButtons[WhatBnt-1]);
   switch(PropertID)
     {
      case BUTTON_TEXTSHOW:
         ObjectSetString(ID,Name,OBJPROP_TEXT,Text);
         return;
      default:
         return;
     };

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlPainel::TextModifyInteger(int WhatTxt,ENUM_TEXT_INTEGER PropertID,long Val)
  {
   int N=ArraySize(NumberTexts);
   if(WhatTxt<=0 || WhatTxt>N)
      return;
   string Name=GetGeralName(OBJGERALNAME,NumberTexts[WhatTxt-1]);
   switch(PropertID)
     {
      case TEXT_FONTCOLOR:
         ObjectSetInteger(ID,Name,OBJPROP_COLOR,Val);
         return;
      case TEXT_FONTSIZE:
         ObjectSetInteger(ID,Name,OBJPROP_FONTSIZE,Val);
         return;
      case TEXT_READONLY:
         ObjectSetInteger(ID,Name,OBJPROP_READONLY,Val);
         return;
      default:
         return;
     };

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlPainel::TextModifyString(int WhatTxt,ENUM_TEXT_STRING PropertID,const string Text)
  {
   int N=ArraySize(NumberTexts);
   if(WhatTxt<=0 || WhatTxt>N)
      return;
   string Name=GetGeralName(OBJGERALNAME,NumberTexts[WhatTxt-1]);
   switch(PropertID)
     {
      case TEXT_TEXTSHOW:
         ObjectSetString(ID,Name,OBJPROP_TEXT,Text);
         return;
      default:
         return;
     };

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlPainel::PanelSetFont(const string NameFont)
  {
   if(ObjectSetString(ID,PanelName,OBJPROP_FONT,NameFont))
     {
      FontName=NameFont;
      string Name;
      for(int i=1; i<=NumbersObjects; i++)
        {
         Name=GetGeralName(OBJGERALNAME,i);
         ObjectSetString(ID,Name,OBJPROP_FONT,FontName);

        }

     }

  }


//+------------------------------------------------------------------+
//|PRIVATE DEFINITIONS                                               |
//+------------------------------------------------------------------+
long CControlPainel::SetXDistance(ENUM_BASE_CORNER Corner,long MARGIM,long WIDTH)
  {
   if(Corner==CORNER_LEFT_LOWER || Corner==CORNER_LEFT_UPPER)
     {
      return MARGIM;
     }
   return MARGIM+WIDTH;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long CControlPainel::SetYDistance(ENUM_BASE_CORNER Corner,long MARGIM,long HEIGTH)
  {
   if(Corner==CORNER_LEFT_LOWER || Corner==CORNER_RIGHT_LOWER)
     {
      return MARGIM+HEIGTH;
     }
   return MARGIM;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlPainel::ChangePanelAppearence()
  {
   if(!ObjectSetInteger(ID,PanelName,OBJPROP_BGCOLOR,PanelBGColor))
      return false;
   if(!ObjectSetInteger(ID,PanelName,OBJPROP_BORDER_TYPE,PanelBorder))
      return false;
   if(!ObjectSetInteger(ID,PanelName,OBJPROP_BORDER_COLOR,PanelBorderColor))
      return false;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlPainel::SetObjectYDimensions()
  {
   int N=NumbersObjects+1;
   long PHeigth=PanelHeight;
   ObjYMargim=(long)((PHeigth*OBJMARGIMX)/N);
   ObjYSize=(long)(PHeigth*(1-OBJMARGIMX)/NumbersObjects);
   long Temp=(long)(PHeigth-ObjYMargim*N-ObjYSize*NumbersObjects);
   long K=0;
   long TempK=0;
   for(int i=0; i<30; i++)
     {
      TempK=(ObjYMargim-Temp-i)/2;
      if(TempK%2!=0)
         continue;
      K=TempK/2;
      break;
     }
   ObjAddYMargim=-K;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlPainel::SetObjectXDimensions()
  {
////////////////////////////
   long PWidth=PanelWidth;
   ObjXMargim=(long)(PWidth*(OBJMARGIMY)/2);
   ObjXSize=(long)(PWidth*(1-OBJMARGIMY));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CControlPainel::GetGeralName(const string GName,int N)const
  {
   string Temp=PanelName;
   StringAdd(Temp,GName);
   StringAdd(Temp,IntegerToString(N));
   return Temp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long CControlPainel::SetYMargimObj(int i)
  {
   if(PanelCorner==CORNER_LEFT_UPPER || PanelCorner==CORNER_RIGHT_UPPER)
     {
      return ((ObjYMargim*i)+(ObjYSize*(i-1))+ObjAddYMargim);
     }
   long PanelW=PanelHeight;
   return (PanelW-((ObjYMargim*i)+(ObjYSize*(i-1)))-ObjAddYMargim);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlPainel::SetObjectsPlace()
  {
   SetObjectYDimensions();
   SetObjectXDimensions();
   string Name;
   long MargimY;
   for(int i=1; i<=NumbersObjects; i++)
     {
      Name=GetGeralName(OBJGERALNAME,i);
      MargimY=YMargim+SetYMargimObj(i);
      ObjectSetInteger(ID,Name,OBJPROP_CORNER,PanelCorner);
      ObjectSetInteger(ID,Name,OBJPROP_YDISTANCE,MargimY);
      ObjectSetInteger(ID,Name,OBJPROP_YSIZE,ObjYSize);
      ObjectSetInteger(ID,Name,OBJPROP_XDISTANCE,SetXDistance(PanelCorner,XMargim+ObjXMargim,ObjXSize));
      ObjectSetInteger(ID,Name,OBJPROP_XSIZE,ObjXSize);
      ObjectSetString(ID,Name,OBJPROP_FONT,FontName);
      //ObjectSetString(ID,Name,OBJPROP_);
     }




  }


#endif
//+------------------------------------------------------------------+