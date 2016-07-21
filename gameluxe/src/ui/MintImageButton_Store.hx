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
	private var is_over : Bool;
	
	public function new(parent : Control, name : String, pos : Vector, size : Vector, image_path : String) 
	{
		is_over = false;
		
		textures = new MintImageButton_StoreData(image_path);
		super(parent, name, pos, size, get_texture());
	}
	
	override public function mouseenter(e:MouseEvent) 
	{
		is_over = true;
		update_button();
	}
	
	override public function mouseleave(e:MouseEvent) 
	{
		is_over = false;
		update_button();
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
		//trace(texture);
		var renderer = cast(renderer, mint.render.luxe.Image);
		//trace(renderer.visual.texture);
		//return;
		renderer.visual.texture = Luxe.resources.texture(texture);
	}
	
	override public function update_button() 
	{
		change_texture(get_texture());
		
		super.update_button();
	}
	
	private function get_texture() : String
	{
		var tex = textures.tex_locked;
		
		if (is_equipped)
		{
			tex = textures.tex_unlocked_selected;
		}
		else if(is_unlocked)
		{
			if (is_over)
			{
				tex = textures.tex_unlocked_over;
			}
			else
			{
				tex = textures.tex_unlocked;
			}
		}
		else
		{
			if (is_over)
			{
				tex = textures.tex_locked_over;
			}
			else
			{
				tex = textures.tex_locked;
			}
		}
		
		return tex;
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