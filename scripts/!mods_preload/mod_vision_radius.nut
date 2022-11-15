::VisionRadius <- {
	ID = "mod_vision_radius",
	Name = "Vision Radius",
	Version = "2.0.0",
};

::VisionRadius.Colors <- {
	InnerCircle = ::createColor("#ffffff")
}
::VisionRadius.Config <- {
	NormalBrush = "vision_radius",
	SimpleBrush = "vision_radius_inner",
	OuterSprite = "vision_radius",
	InnerSprite = "vision_radius_inner",
}

::VisionRadius.getBrush <- function()
{
	local boolVal = ::VisionRadius.Mod.ModSettings.getSetting("vision_radius_circle_only").getValue();
	return boolVal ? ::VisionRadius.Config.SimpleBrush : ::VisionRadius.Config.NormalBrush
}

::mods_registerMod(::VisionRadius.ID, ::VisionRadius.Version);
::mods_queue(null, "mod_msu", function()
{
	::VisionRadius.Mod <- ::MSU.Class.Mod(::VisionRadius.ID, ::VisionRadius.Version, ::VisionRadius.Name);
	local generalPage = ::VisionRadius.Mod.ModSettings.addPage("General");
	generalPage.addBooleanSetting("vision_radius_circle_only", false, "Simple circle only", 
		"With this selected, the radius is depicted with a simple circle."
		).addCallback(function(_newVal){
		if (::MSU.Utils.getActiveState().ClassName == "world_state")
		{
			::World.State.getPlayer().getSprite(::VisionRadius.Config.OuterSprite).setBrush(::VisionRadius.getBrush());
		}
	})

	generalPage.addBooleanSetting("vision_radius_display_inner_circle", false, "Add Inner Circle", 
		"Adds an inner circle at 0.8x the size of the outer circle. This helps you find locations that have a lowwer visibility value, such as the Hunting Grounds."
		).addCallback(function(_newVal){
		if (::MSU.Utils.getActiveState().ClassName == "world_state")
		{
			::World.State.getPlayer().getSprite(::VisionRadius.Config.InnerSprite).Visible = _newVal;
		}
	})

	generalPage.addColorPickerSetting("vision_radius_inner_circle_color", "255,255,255,1.0", "Inner Circle Color").addCallback(function(_newVal)
	{
		::VisionRadius.Colors.InnerCircle = ::createColor(::VisionRadius.Mod.ModSettings.getSetting("vision_radius_inner_circle_color").getValueAsHexString());
		if (::MSU.Utils.getActiveState().ClassName == "world_state")
		{
			::World.State.getPlayer().getSprite("vision_radius_inner").Color = ::VisionRadius.Colors.InnerCircle;
		}
	});
	::mods_hookExactClass("entity/world/player_party", function(o){
		local onInit = o.onInit;
		o.onInit = function(){
			onInit();
			local visionRadius = this.addSprite(::VisionRadius.Config.OuterSprite);
			visionRadius.setBrush(::VisionRadius.getBrush());
			visionRadius.Scale = 0;
			visionRadius.Visible = true;
			local innerRadius = this.addSprite(::VisionRadius.Config.InnerSprite)
			innerRadius.setBrush(::VisionRadius.Config.SimpleBrush);
			innerRadius.Scale = 0;
			innerRadius.Color = ::VisionRadius.Colors.InnerCircle;
			innerRadius.Visible = ::VisionRadius.Mod.ModSettings.getSetting("vision_radius_display_inner_circle").getValue();
		}
		local onUpdate = o.onUpdate
		o.onUpdate = function(){
			onUpdate();
			local visionRadius = this.getSprite(::VisionRadius.Config.OuterSprite);
			visionRadius.Scale = (this.getVisionRadius() / 200.0);
			local innerRadius = this.getSprite(::VisionRadius.Config.InnerSprite);
			innerRadius.Scale = (this.getVisionRadius() / 400.0) * 0.6;
		}
	})
})