//-----------------------------------------------------------------------------
// Torque
// Copyright GarageGames, LLC 2011
//-----------------------------------------------------------------------------

#ifndef _PLATFORMFONT_H_
#define _PLATFORMFONT_H_

#ifndef _TORQUE_TYPES_H_
#include "platform/types.h"
#endif

//-------------------------------------------------------------------------

template <class T> class Vector;

//-------------------------------------------------------------------------

enum FontCharset
{
    TGE_ANSI_CHARSET = 0,
    TGE_SYMBOL_CHARSET,
    TGE_SHIFTJIS_CHARSET,
    TGE_HANGEUL_CHARSET,
    TGE_HANGUL_CHARSET,
    TGE_GB2312_CHARSET,
    TGE_CHINESEBIG5_CHARSET,
    TGE_OEM_CHARSET,
    TGE_JOHAB_CHARSET,
    TGE_HEBREW_CHARSET,
    TGE_ARABIC_CHARSET,
    TGE_GREEK_CHARSET,
    TGE_TURKISH_CHARSET,
    TGE_VIETNAMESE_CHARSET,
    TGE_THAI_CHARSET,
    TGE_EASTEUROPE_CHARSET,
    TGE_RUSSIAN_CHARSET,
    TGE_MAC_CHARSET,
    TGE_BALTIC_CHARSET
};

//-------------------------------------------------------------------------

const char *getFontCharSetName(const U32 charSet);

//-------------------------------------------------------------------------

class PlatformFont
{
public:
    struct CharInfo
    {
        S16 bitmapIndex;     // Note: -1 indicates character is NOT to be rendered, i.e., \n, \r, etc.
        U32  xOffset;        // x offset into bitmap sheet
        U32  yOffset;        // y offset into bitmap sheet
        U32  width;          // width of character (pixels)
        U32  height;         // height of character (pixels)
        S32  xOrigin;
        S32  yOrigin;
        S32  xIncrement;
        U8  *bitmapData;     // temp storage for bitmap data
    };
    
    PlatformFont() {}
    virtual ~PlatformFont() {}
    virtual bool isValidChar(const UTF16 ch) const = 0;
    virtual bool isValidChar(const UTF8 *str) const = 0;

    virtual U32 getFontHeight() const = 0;
    virtual U32 getFontBaseLine() const = 0;

    virtual PlatformFont::CharInfo &getCharInfo(const UTF16 ch) const = 0;
    virtual PlatformFont::CharInfo &getCharInfo(const UTF8 *str) const = 0;

    virtual bool create(const char *name, U32 size, U32 charset = TGE_ANSI_CHARSET) = 0;
    static void enumeratePlatformFonts( Vector<StringTableEntry>& fonts, UTF16* fontFamily = NULL );
};

//-------------------------------------------------------------------------

extern PlatformFont *createPlatformFont(const char *name, U32 size, U32 charset = TGE_ANSI_CHARSET);

#endif // _PLATFORMFONT_H_
