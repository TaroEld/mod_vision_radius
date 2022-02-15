local modName = "mod_vision_radius"
::mods_registerMod(modName, 1.0)

::mods_queue(null, null, function()
{
	::mods_hookExactClass("entity/world/player_party", function(o){
		local onInit = o.onInit;
		o.onInit = function(){
			onInit();
			local visionRadius =  this.addSprite("vision_radius");
			visionRadius.setBrush("vision_radius");
			visionRadius.Scale = 0;
			visionRadius.Visible = true;
		}
		local onUpdate = o.onUpdate
		o.onUpdate = function(){
			onUpdate();
			local visionRadius = this.getSprite("vision_radius");
			visionRadius.Scale = this.getVisionRadius() / 400.0;
		}
	})
})