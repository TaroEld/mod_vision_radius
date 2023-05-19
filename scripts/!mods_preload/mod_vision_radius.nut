::VisionRadius <- {
	ID = "mod_vision_radius",
	Name = "Vision Radius",
	Version = "2.0.1",
	Const = {
		TaperingBrush = "vision_radius_tapering",
		LineBrush = "vision_radius_line",
		OuterSprite = "vision_radius_outer",
		InnerSprite = "vision_radius_inner",
	},
	Config = {
		Enabled = true,
		InnerCircle = false,
		InnerCircleScale = 0.8
		LineCircle = false,
		LineColor = ::createColor("#ffffff")
	},
	function getBrush()
	{
		return this.Config.LineCircle ? ::VisionRadius.Const.LineBrush : ::VisionRadius.Const.TaperingBrush;
	},
	function getSpriteScaleMultiplier()
	{
		// circle sprite fills out the png while tapering doesn't, so need to adapt the scaling
		return this.Config.LineCircle ? 0.4 : 1.0;
	},
	function updateSpritesOnCampaign()
	{
		if (!::MSU.Utils.hasState("world_state"))
			return;

		local outerSprite = ::World.getPlayerEntity().getSprite(this.Const.OuterSprite);
		outerSprite.setBrush(this.getBrush());
		outerSprite.Color = this.Config.LineColor;
		outerSprite.Visible = this.Config.Enabled;

		local innerSprite = ::World.getPlayerEntity().getSprite(this.Const.InnerSprite);
		innerSprite.setBrush(this.getBrush());
		innerSprite.Color = this.Config.LineColor;
		innerSprite.Visible = this.Config.Enabled && this.Config.InnerCircle;
	},
};

::mods_registerMod(::VisionRadius.ID, ::VisionRadius.Version, ::VisionRadius.Name);
::mods_queue(null, "mod_msu(>=1.1.1)", function()
{
	::VisionRadius.Mod <- ::MSU.Class.Mod(::VisionRadius.ID, ::VisionRadius.Version, ::VisionRadius.Name);
	local generalPage = ::VisionRadius.Mod.ModSettings.addPage("General");
	generalPage.addBooleanSetting("vision_radius_enabled", true, "Enabled", 
		"Enable/Disable circles."
		).addAfterChangeCallback(function(_){
			::VisionRadius.Config.Enabled = this.getValue();
			::VisionRadius.updateSpritesOnCampaign();
	})

	generalPage.addBooleanSetting("vision_radius_line_circle", false, "Line circles", 
		"Display the circle(s) as lines instead fo the fog of war circle."
		).addAfterChangeCallback(function(_){
			::VisionRadius.Config.LineCircle = this.getValue();
			::VisionRadius.updateSpritesOnCampaign();
	})

	generalPage.addColorPickerSetting("vision_radius_line_color", "255,255,255,1.0", "Color of 'line' circles").addAfterChangeCallback(function(_)
	{
		::VisionRadius.Config.LineColor = ::createColor(this.getValueAsHexString());
		::VisionRadius.updateSpritesOnCampaign();
	});

	generalPage.addBooleanSetting("vision_radius_display_inner_circle", false, "Add Inner Circle", 
		"Adds an inner circle at 0.8x the size of the outer circle. This helps you find locations that have a lower visibility value, such as the Hunting Grounds."
		).addAfterChangeCallback(function(_){
			::VisionRadius.Config.InnerCircle = this.getValue();
			::VisionRadius.updateSpritesOnCampaign();
	})

	generalPage.addRangeSetting("vision_radius_inner_circle_scale", ::VisionRadius.Config.InnerCircleScale, 0.1, 2.0, 0.01, "Inner Circle Scale", 
		"Scale of the inner circle. This helps you find locations that have a lower visibility value, such as the Hunting Grounds. The value you want depends on the target. 
		For example, Witch Hut has a 0.9 multiplier, and is in a forest which has a 0.5 multiplier, so the final value is 0.9*0.5 = 0.45."
		).addAfterChangeCallback(function(_){
			::VisionRadius.Config.InnerCircleScale = this.getValue();
			::VisionRadius.updateSpritesOnCampaign();
	})


	::mods_hookExactClass("entity/world/player_party", function(o){
		local onInit = o.onInit;
		o.onInit = function(){
			onInit();
			local visionRadius = this.addSprite(::VisionRadius.Const.OuterSprite);
			visionRadius.Scale = 0;
			visionRadius.Visible = true;
			local innerRadius = this.addSprite(::VisionRadius.Const.InnerSprite)
			innerRadius.Scale = 0;
			::VisionRadius.updateSpritesOnCampaign();
		}
		local onUpdate = o.onUpdate
		o.onUpdate = function(){
			onUpdate();
			if (!::VisionRadius.Config.Enabled)
				return;
			local spriteScaleMultiplier = ::VisionRadius.getSpriteScaleMultiplier();
			this.getSprite(::VisionRadius.Const.OuterSprite).Scale = (this.getVisionRadius() / 200.0) * spriteScaleMultiplier;
			this.getSprite(::VisionRadius.Const.InnerSprite).Scale = (this.getVisionRadius() / 200.0) * ::VisionRadius.Config.InnerCircleScale * spriteScaleMultiplier;
		}
	})
})