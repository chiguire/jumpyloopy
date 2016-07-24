package ui;

import luxe.Color;
import luxe.options.ParcelProgressOptions;
import luxe.ParcelProgress;

/**
 * ...
 * @author Aik
 */
typedef ParcelProgressExOptions =
{
	> ParcelProgressOptions,
	var background_texture : String;
};
 
class ParcelProgressEx extends ParcelProgress
{
	public function new(_options:ParcelProgressExOptions) 
	{
		super(_options);
		
		background.texture = _options.background_texture;
	}	
}