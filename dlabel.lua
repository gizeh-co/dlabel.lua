--nice folder for gizeh €co+ sueurised of trackzoin

local PANEL = {}

AccessorFunc( PANEL, "m_colText",		"TextColor" )
AccessorFunc( PANEL, "m_colTextStyle",	"TextStyleColor" )
AccessorFunc( PANEL, "m_FontName",		"Font" )

AccessorFunc( PANEL, "m_bDoubleClicking",		"DoubleClickingEnabled",	FORCE_BOOL )
AccessorFunc( PANEL, "m_bAutoStretchVertical",	"AutoStretchVertical",		FORCE_BOOL )
AccessorFunc( PANEL, "m_bIsMenuComponent",		"IsMenu",					FORCE_BOOL )

AccessorFunc( PANEL, "m_bBackground",	"PaintBackground",	FORCE_BOOL )
AccessorFunc( PANEL, "m_bBackground",	"DrawBackground",	FORCE_BOOL )
AccessorFunc( PANEL, "m_bDisabled",		"Disabled",			FORCE_BOOL )

AccessorFunc( PANEL, "m_bIsToggle",		"IsToggle",		FORCE_BOOL )
AccessorFunc( PANEL, "m_bToggle",		"Toggle",		FORCE_BOOL )

AccessorFunc( PANEL, "m_bBright",		"Bright",		FORCE_BOOL )
AccessorFunc( PANEL, "m_bDark",			"Dark",			FORCE_BOOL )
AccessorFunc( PANEL, "m_bHighlight",	"Highlight",	FORCE_BOOL )

AccessorFunc( PANEL, "m_bHackFunction",	"HackFunction",	FORCE_BOOL )

Derma_Install_Convar_Functions(PANEL)

--force sueur of trackzoin 

function PANEL:Init()

	self:SetIsToggle( false )
	self:SetToggle( false )
	self:SetDisabled( false )
	self:SetMouseInputEnabled( false )
	self:SetKeyboardInputEnabled( false )
	self:SetDoubleClickingEnabled( true )
	self:SetTall( 20 )
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )
        self:SetHackFunction(false)

	self:SetFont( "DermaDefault" )

end

function PANEL:SetFont( strFont )

	self.m_FontName = strFont
	self:SetFontInternal( self.m_FontName )
	self:ApplySchemeSettings()

end

function PANEL:SetTextColor( clr )

	self.m_colText = clr
	self:UpdateFGColor()

end
PANEL.SetColor = PANEL.SetTextColor

function PANEL:GetColor()

	return self.m_colText || self.m_colTextStyle

end

function PANEL:UpdateFGColor()

	local col = self:GetTextStyleColor()
	if ( self:GetTextColor() ) then col = self:GetTextColor() end

	if ( !col ) then return end

	self:SetFGColor( col.r, col.g, col.b, col.a )

end

function PANEL:Toggle()

	if ( !self:GetIsToggle() ) then return end

	self:SetToggle( !self:GetToggle() )
	self:OnToggled( self:GetToggle() )

end

function PANEL:SetDisabled( bDisabled )

	self.m_bDisabled = bDisabled
	self:InvalidateLayout()

end

function PANEL:SetEnabled( bEnabled )

	self:SetDisabled( !bEnabled )

end

function PANEL:IsEnabled()

	return !self:GetDisabled()

end

function PANEL:UpdateColours( skin )

	if ( self:GetBright() ) then return self:SetTextStyleColor( skin.Colours.Label.Bright ) end
	if ( self:GetDark() ) then return self:SetTextStyleColor( skin.Colours.Label.Dark ) end
	if ( self:GetHighlight() ) then return self:SetTextStyleColor( skin.Colours.Label.Highlight ) end

	return self:SetTextStyleColor( skin.Colours.Label.Default )

end

function PANEL:ApplySchemeSettings()

	self:UpdateColours( self:GetSkin() )

	self:UpdateFGColor()

end

function PANEL:Think()

	if ( self:GetAutoStretchVertical() ) then
		self:SizeToContentsY()
	end

end

function PANEL:PerformLayout()

	self:ApplySchemeSettings()

end


function PANEL:OnCursorEntered()

	self:InvalidateLayout( true )

end

function PANEL:OnCursorExited()

	self:InvalidateLayout( true )

end

function PANEL:OnMousePressed( mousecode )

	if ( self:GetDisabled() ) then return end

	if ( mousecode == MOUSE_LEFT && !dragndrop.IsDragging() && self.m_bDoubleClicking ) then

		if ( self.LastClickTime && SysTime() - self.LastClickTime < 0.2 ) then

			self:DoDoubleClickInternal()
			self:DoDoubleClick()
			return

		end

		self.LastClickTime = SysTime()

	end

	if ( self:IsSelectable() && mousecode == MOUSE_LEFT && input.IsShiftDown() ) then

		return self:StartBoxSelection()

	end

	self:MouseCapture( true )
	self.Depressed = true
	self:OnDepressed()
	self:InvalidateLayout( true )
	self:DragMousePress( mousecode )

end

function PANEL:OnMouseReleased( mousecode )

	self:MouseCapture( false )

	if ( self:GetDisabled() ) then return end
	if ( !self.Depressed && dragndrop.m_DraggingMain != self ) then return end

	if ( self.Depressed ) then
		self.Depressed = nil
		self:OnReleased()
		self:InvalidateLayout( true )
	end

	if ( self:DragMouseRelease( mousecode ) ) then
		return
	end
	
	if ( self:IsSelectable() && mousecode == MOUSE_LEFT ) then

		local canvas = self:GetSelectionCanvas()
		if ( canvas ) then
			canvas:UnselectAll()
		end

	end

	if ( !self.Hovered ) then return end

	self.Depressed = true

	if ( mousecode == MOUSE_RIGHT ) then
		self:DoRightClick()
	end

	if ( mousecode == MOUSE_LEFT ) then
		self:DoClickInternal()
		self:DoClick()
	end

	if ( mousecode == MOUSE_MIDDLE ) then
		self:DoMiddleClick()
	end

	self.Depressed = nil

end

function PANEL:OnReleased()
end

function PANEL:OnDepressed()
end

function PANEL:OnToggled( bool )
end

function PANEL:DoClick()

	self:Toggle()

end

function PANEL:DoRightClick()
end

function PANEL:DoMiddleClick()
end

function PANEL:DoClickInternal()
end

function PANEL:DoDoubleClick()
end

function PANEL:DoDoubleClickInternal()
end

function PANEL:GetHack(bools,string)
   if bools and string!="" then
   	self.m_bHackFunction = bools
   	if self.m_bHackFunction!=false then 
      		return print(string)
   	end 
   end
end

function PANEL:SetTableCache(bool)
     if bool == true then
         local TableCache=TableCache or {}
         return print("[+] Cache Table is set")
     else
         return print("[-] Cache Table did not set")
     end
end


function PANEL:AddInCache(string,value)
	if IsValid(string) and string!="" and value!="" and IsValid(value)then
		table.insert(TableCache[string],value)
		return print("[+] your table : CacheTable value : "..value.." has access value by name:GetValueInCache(‘"..string.."’) been cached successfully") 
	else
		return print("[-] your string doesn't exist")
	end
end
 
function PANEL:GetValueInCache(string)
        if IsValid(string) and string!="" then
	      return TableCache[string]
        end
end

derma.DefineControl( "DLabel", "", PANEL, "Label" )
