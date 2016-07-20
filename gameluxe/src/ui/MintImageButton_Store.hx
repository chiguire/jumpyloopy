package ui;
import luxe.Vector;
import mint.Control;
import mint.Image;
import mint.types.Types.MouseEvent;

/**
 * ...
 * @author ...
 */
class MintImageButton_Store extends MintImageButton
{
	var textures : MintImageButton_StoreData;
	public var is_unlocked : Bool;
	public var is_equipped : Bool;

	public function new(parent : Control, name : String, pos : Vector, size : Vector, image_path : String, ?onclick : Void->Void) 
	{
		is_unlocked = Main.achievement_manager.is_item_unlocked(name);
		is_equipped = name == Main.achievement_manager.current_character_name ? true : false;
		
		textures = new MintImageButton_StoreData(image_path);
		var tex = textures.tex_locked;
		if (is_unlocked)
			tex = textures.tex_unlocked;
		if (is_equipped)
			tex = textures.tex_unlocked_selected;
		
		trace(tex);
		super(parent, name, pos, size, tex, onclick);
	}
	
	override public function mouseenter(e:MouseEvent) 
	{
		if(is_unlocked)
			change_texture(textures.tex_unlocked_over);
		else
			change_texture(textures.tex_locked_over);
		
		//super.mouseenter(e);
	}
	
	override public function mouseleave(e:MouseEvent) 
	{
		if(is_unlocked)
			change_texture(textures.tex_unlocked);
		else
			change_texture(textures.tex_locked);
			
		//super.mouseleave(e);
	}
	
	override public function mousedown(e:MouseEvent) 
	{
		if(is_unlocked)
			change_texture(textures.tex_unlocked_selected);
		else
			change_texture(textures.tex_locked);
		
		//super.mousedown(e);
	}
	
	private function change_texture(texture : String)
	{	
		trace(texture);
		var renderer = cast(renderer, mint.render.luxe.Image);
		renderer.visual.texture = Luxe.resources.texture(texture);
	}
}

class MintImageButton_StoreData
{
	public var tex_locked : String;
	public var tex_locked_over : String;
	public var tex_unlocked : String;
	public var tex_unlocked_over : String;
	public var tex_unlocked_selected : String;
	
	public function new(base_tex : String)
	{
		tex_locked = base_tex + "_locked.png";
		tex_locked_over = base_tex + "_locked_selected.png";
		tex_unlocked = base_tex + "_unlocked.png";
		tex_unlocked_over = base_tex + "_unlocked_selected.png";
		tex_unlocked_selected = base_tex + "_unlocked_equipped.png";
	}
}