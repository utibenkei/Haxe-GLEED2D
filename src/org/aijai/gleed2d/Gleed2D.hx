package org.aijai.gleed2d;
import haxe.xml.Fast;
import org.aijai.gleed2d.front.G2DColor;
import org.aijai.gleed2d.front.G2DLevel;
import org.aijai.gleed2d.front.G2DLayer;
import org.aijai.gleed2d.front.G2DPoint;
import org.aijai.gleed2d.front.G2DProperty;
import org.aijai.gleed2d.front.G2DBasic;
import org.aijai.gleed2d.front.G2DEntity;
import org.aijai.gleed2d.front.G2DItem;

/**
 * Parses Gleed2D generated XML files
 * @author Pekka Heikkinen
 */

class Gleed2D implements G2DLevel
{
	/**
	 * Name of the level
	 */
	public var name:String;
	
	/**
	 * Level visibility
	 */
	public var visible:Bool;
	
	/**
	 * Properties associated with level
	 */
	public var properties:Array<G2DProperty>;
	
	/**
	 * Layers within level
	 */
	public var layers:Array<G2DLayer>;
	
	/**
	 * Parse Gleed2D file
	 * @param	source	File contents in plain string format
	 */
	public function new(source:String) 
	{
		source = StringTools.replace(source, "xsi:type", "Type");
		var fast:Fast = new Fast(Xml.parse(source).firstElement());
		Gleed2DBuilder.buildLevel(fast, this);
	}
	
}


private class Gleed2DBuilder {
	
	public static function buildLevel(source:Fast, target:G2DLevel):Void {
		Gleed2DBuilder.buildBasic(source, target);
		Gleed2DBuilder.buildEntity(source, target);
		Gleed2DBuilder.buildLayers(source, target);
	}
	
	public static function buildBasic(source:Fast, target:G2DBasic):Void
	{
		target.name = source.att.Name;
		target.visible = (source.att.Visible == "true") ? true : false;
	}
	
	public static function buildEntity(source:Fast, target:G2DEntity):Void
	{
		target.properties = new Array<G2DProperty>();
		for ( prop in source.node.CustomProperties.nodes.Property )
		{
			var newProp:G2DProperty = new G2DPropertyImpl();
			newProp.name = prop.att.Name;
			newProp.description = prop.att.Description;
			switch (prop.att.Type)
			{
				case "bool":
					newProp.type = G2DPropertyType.Boolean;
					newProp.boolean = (prop.node.boolean.innerData == "true") ? true : false;
				case "string":
					newProp.type = G2DPropertyType.FreeText;
					newProp.freeText = prop.node.string.innerData;
				case "Vector2":
					newProp.type = G2DPropertyType.Vector2;
					newProp.vector2 = createPoint(prop.node.Vector2);
				case "Color":
					newProp.type = G2DPropertyType.Color;
					newProp.color = createColor(prop.node.Color);
				case "Item":
					newProp.type = G2DPropertyType.Item;
					newProp.item = prop.innerData;
			}
			target.properties.push(newProp);
		}
	}
	
	public static inline function buildLayers(source:Fast, target:G2DLevel):Void {
		target.layers = new Array<G2DLayer>();
		for ( layer in source.node.Layers.nodes.Layer ) {
			var newLayer:G2DLayer = new G2DLayerImpl();
			buildBasic( layer, newLayer );
			newLayer.scroll = createPoint(layer.node.ScrollSpeed);
			buildItems(layer, newLayer);
			target.layers.push(newLayer);
		}
	}
	
	public static inline function buildItems(source:Fast, target:G2DLayer):Void {
		target.items = new Array<G2DItem>();
		for ( item in source.node.Items.nodes.Item ) {
			// Support only texture items for now
			if (item.att.Type == "TextureItem") {
				target.items.push(createTextureItem(item));
			}
		}
	}
	
	public static inline function createTextureItem(source:Fast):G2DItem {
		var i:G2DItem = new G2DItemImpl();
		buildEntity(source, i);
		buildBasic(source, i);
		i.assetName			= source.node.asset_name.innerData;
		i.flipHorizontal	= (source.node.FlipHorizontally.innerData == "true") ? true : false;
		i.flipVertical		= (source.node.FlipVertically.innerData == "true") ? true : false;
		i.origin			= createPoint(source.node.Origin);
		i.position			= createPoint(source.node.Position);
		i.rotation			= Std.parseFloat(source.node.Rotation.innerData);
		i.scale				= createPoint(source.node.Scale);
		i.textureFilename	= source.node.texture_filename.innerData;
		i.tint				= createColor(source.node.TintColor);
		return i;
	}
	
	public static inline function createPoint(source:Fast):G2DPoint {
		var p:G2DPoint = new G2DPointImpl();
		p.x = Std.parseFloat(source.node.X.innerData);
		p.y = Std.parseFloat(source.node.Y.innerData);
		return p;
	}
	
	public static inline function createColor(source:Fast):G2DColor {
		var c:G2DColor = new G2DColorImpl();
		c.red	= Std.parseInt(source.node.R.innerData);
		c.green	= Std.parseInt(source.node.G.innerData);
		c.blue	= Std.parseInt(source.node.B.innerData);
		c.alpha	= Std.parseInt(source.node.A.innerData);
		return c;
	}
}

private class G2DPointImpl implements G2DPoint {
	public function new() {}
	public var x:Float;
	public var y:Float;
}

private class G2DColorImpl implements G2DColor {
	public function new() {}
	public var red:Int;
	public var green:Int;
	public var blue:Int;
	public var alpha:Int;
}

private class G2DItemImpl implements G2DItem {
	public function new() {}
	public var name:String;
	public var visible:Bool;
	public var type:G2DItemType;
	public var position:G2DPoint;
	public var rotation:Float;
	public var scale:G2DPoint;
	public var flipHorizontal:Bool;
	public var flipVertical:Bool;
	public var origin:G2DPoint;
	public var textureFilename:String;
	public var assetName:String;
	public var properties:Array<G2DProperty>;
	public var tint:G2DColor;
}


private class G2DLayerImpl implements G2DLayer {
	public function new() {}
	public var name:String;
	public var visible:Bool;
	public var items:Array<G2DItem>;
	public var scroll:G2DPoint;
}



private class G2DPropertyImpl implements G2DProperty {
	public function new() {}
	public var name:String;
	public var type:G2DPropertyType;
	public var description:String;
	public var freeText:String;
	public var boolean:Bool;
	public var vector2:G2DPoint;
	public var color:G2DColor;
	public var item:String;
}
