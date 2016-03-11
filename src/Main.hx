package;

import luxe.collision.shapes.Polygon;
import luxe.Color;
import luxe.Input;
import luxe.Input.MouseEvent;
import luxe.Sprite;
import luxe.Vector;
import pathfinding.PolygonMap;
import pathfinding.Polygon;
import phoenix.Texture.FilterType;

class Main extends luxe.Game 
{
	public var screen_mouse:Vector = new Vector();
	public var view_mouse:Vector = new Vector();
	public var world_mouse:Vector = new Vector();
	
	public var walkpath:Array<Int>;
	public var polygonMap:PolygonMap;
	public var backgroundsprite2:Sprite;
	public var currentwalknode:Int = 0;
	public var walkspeed: Float = 3;
	public var playersprite:Sprite;
	public var walktox: Float;
	public var walktoy: Float;
	public var walking:Bool = false;
	
	public var showlines = true;
	
	//ready() is called once after the application is initialized
	override function ready() 
	{
		
		
		//Create the default background
		var texture = Luxe.resources.texture('assets/background.png');
		texture.filter_mag = FilterType.nearest;
		var backgroundsprite:Sprite = new Sprite( {
			name : 'background',
			texture : texture,
			centered: false,
			pos: new Vector(0,0),
		});
		
		//Create the background of example 2 (visible false)
		var texture = Luxe.resources.texture('assets/background2.png');
		texture.filter_mag = FilterType.nearest;
		backgroundsprite2 = new Sprite( {
			name : 'background2',
			texture : texture,
			centered: false,
			pos: new Vector(0, 0),
			visible: false,
		});
		
		//Create the 'player'
		var texture = Luxe.resources.texture('assets/player.png');
		texture.filter_mag = FilterType.nearest;
		playersprite = new Sprite( {
			name : 'player',
			texture : texture,
			centered: false,
			scale: new Vector(3, 3),
			origin:new Vector(texture.width / 2, texture.height),
		});
		
		//Draw that help text
		Luxe.draw.text(
			{
				pos : new Vector(5,5),
				point_size : 20,
				depth : 250,
				immediate: false,
				text : 'Press 1 and 2 to switch between examples\nPress X to toggle lines',
				color : new Color(1, 1, 1, 1),
			}
		);
		
		//initialize walkable area. 
		initializeWalkableArea(1);
	}
	
	//update is called every frame
	override function update(dt:Float) 
	{
		//If walking is true, then walk some more
		if (walking) {
			walkPlayer();
		}
		//else calculate the walk path from the play position to the mouse position
		else {
			walkpath = polygonMap.calculatePath(new Vector(playersprite.pos.x, playersprite.pos.y), world_mouse);
		}
		//Draw the path and walkable area
		if (showlines) drawPath();
	}
	
	//Draw that area and the graph
	function drawPath()
	{
		//Draw the walkable area-polygon
		var linep0:Vector = new Vector(0, 0);
		var linep1:Vector = new Vector(0, 0);
		for (polygon in polygonMap.polygons) {
			Luxe.draw.poly( {
				immediate : true,
				solid : false,
				color: new Color(0, 0,1,1),
				points : polygon.vertices,
				depth: 11
			});
			var p0 = new Vector(polygon.vertices[polygon.vertices.length - 1].x, polygon.vertices[polygon.vertices.length - 1].y);
			var p1 = new Vector(polygon.vertices[0].x, polygon.vertices[0].y);
			Luxe.draw.line( {
				immediate : true,
				color: new Color(0, 0,1,1),
				p0 : p0,
				p1 : p1,
				depth: 11
			});
			//Draw all the vertices of the walkable area polygon
			for (v in polygon.vertices) {
				Luxe.draw.circle( {
					immediate : true,
					x : v.x,
					y : v.y,
					r : 3,
					color : new Color(0, 0,1,1),
					depth: 11
				});
			}
		}
		//Draw the graph
		if (polygonMap.walkgraph != null) {
			for (edge_from in polygonMap.walkgraph.edges) {
				for (edge in edge_from) {
					var p0 = new Vector(polygonMap.walkgraph.nodes[edge.from].pos.x, polygonMap.walkgraph.nodes[edge.from].pos.y);
					var p1 = new Vector(polygonMap.walkgraph.nodes[edge.to].pos.x, polygonMap.walkgraph.nodes[edge.to].pos.y);
					Luxe.draw.line( {
						immediate : true,
						color: new Color(0, 1, 0, 0.2),
						p0 : p0,
						p1 : p1,
						depth: 11
					});
				}
			}
			var i:Int = 0;
			for (node in walkpath) {
				var c:Color = new Color(1, 1, 1, 1);
				if (i == 0) c = new Color(0, 1, 0, 1);
				if (i == walkpath.length - 1) c = new Color(1, 0, 0, 1);

				var s = i + 1;
				if (s < walkpath.length) {
					Luxe.draw.line( {
						immediate : true,
						color: new Color(1, 1,1,1),
						p0 : new Vector(polygonMap.walkgraph.nodes[walkpath[i]].pos.x, polygonMap.walkgraph.nodes[walkpath[i]].pos.y),
						p1 : new Vector(polygonMap.walkgraph.nodes[walkpath[s]].pos.x, polygonMap.walkgraph.nodes[walkpath[s]].pos.y),
						depth: 11
					});
				}

				Luxe.draw.circle( {
					immediate : true,
					x : polygonMap.walkgraph.nodes[node].pos.x,
					y : polygonMap.walkgraph.nodes[node].pos.y,
					r : 4,
					color : c,
					depth: 11
				});
				i++;
			}
			for (co in polygonMap.vertices_concave) {
				Luxe.draw.circle( {
					immediate : true,
					x : co.x,
					y : co.y,
					r : 4,
					color : new Color(1,1,0,1),
					depth: 11
				});
			}
		}

	}
	
	private function walkPlayer() {
		//Set temp walkto position to the current node the play is walking towards
		var tempwalktox = polygonMap.walkgraph.nodes[currentwalknode].pos.x;
		var tempwalktoy = polygonMap.walkgraph.nodes[currentwalknode].pos.y;
		
		//Create a vector for the current pos and a vector for the destionation pos
		var b:Vector = new Vector(playersprite.pos.x, playersprite.pos.y);
		var a:Vector = new Vector(tempwalktox, tempwalktoy);
		//Create a vector from current pos to dest pos
		var c:Vector = Vector.Subtract(a, b);
		//if the length of that vector > walkspeed, normalize that vector and make the length = walkspeed
		//In plain english:if the destination is more that 'walkspeed' away, walk 'walkspeed' pixels towards it.
		if (c.length >= (walkspeed)) {
			c.normalize();
			c.x = c.x * (walkspeed);
			c.y = c.y * (walkspeed);
		}
		//Add the new vector to the current position vector
		b = b.add(c);
		//update play position
		playersprite.pos.x = b.x;
		playersprite.pos.y = b.y;
		
		//If the end of the walkpath is not yet reached
		//and the player is currently at the 'current walk node', then set the currentwalknode to the next node from the list
		if (walkpath.length > 0) {
			if (tempwalktox == playersprite.pos.x && tempwalktoy == playersprite.pos.y) {
				currentwalknode = walkpath.pop();
			}
		}
		//if the player is at its final destination, stop walking
		if (walktox == playersprite.pos.x && walktoy == playersprite.pos.y) {
			walking = false;
		}

	}
	
	//---------------------------------- Input ---------------------------------------
	
	override function onkeyup(e:KeyEvent) 
	{
		//Press 1 to load exmaple 1
		if (e.keycode == Key.key_1) {
			backgroundsprite2.visible = false;
			initializeWalkableArea(1);
		}
		//Or 2 to switch to example 2
		if (e.keycode == Key.key_2) {
			backgroundsprite2.visible = true;
			initializeWalkableArea(2);
		}
		//Or X to toggle drawing of polygons and lines
		if (e.keycode == Key.key_x) {
			showlines = !showlines;
		}
	}
	
	//When mouse is moving, set the mouseposition variables
	override function onmousemove( e:luxe.MouseEvent ) {
		setPos(e.pos);
    }

	//When mouse is up, set the mouseposition variables
	//and then start walking when player is not walking
	override function onmouseup( e:luxe.MouseEvent ) {
		setPos(e.pos);
		if (!walking) {
			walkpath.reverse();
			currentwalknode = walkpath.pop();
			walking = true;
			walktox = polygonMap.targetx;
			walktoy = polygonMap.targety;
		}
    }

	//Set the mouse position variables
	//Useful when srolling and zooming and stuff
	private function setPos(pos:Vector) {
		//mouse position relative to the screen
		screen_mouse = pos;
		
		//mouse poistion relative to the 'view'
		view_mouse.set_xy(screen_mouse.x - Luxe.camera.viewport.x, screen_mouse.y - Luxe.camera.viewport.y);
		
		//mouse position in the 'world'
        world_mouse = Luxe.camera.screen_point_to_world(view_mouse );
	}
	
	
	//---------------------------------- Initialization ---------------------------------------
	
	//config() is called once before 'ready'
	override function config( config:luxe.AppConfig ) {
		//Set the window size
		config.window.width = 512;
        config.window.height = 384;
		//Title of the app
		config.window.title = 'Example - Pathfinding in a point and click adventure game';
		
		//Preload textures
		config.preload.textures = [
            { id:'assets/background.png' },
			{ id:'assets/background2.png' },
			{ id:'assets/player.png' },
        ];
        return config;

    }
	
		
	function initializeWalkableArea(p:Int) {
		//Reset all variables to defaults
		playersprite.pos.set_xy(63, 290);
		walking = false;
		walktox = 0;
		walktoy = 0;
		currentwalknode = 0;
		var polyid:Int = 0;
		
		//Create new polygonMap
		polygonMap = new PolygonMap(Luxe.screen.width, Luxe.screen.height);
		polygonMap.polygons[polyid] = new Polygon();
		if (p == 1) {
			polygonMap.polygons[polyid].addPoint(5,248);
			polygonMap.polygons[polyid].addPoint(235,248);
			polygonMap.polygons[polyid].addPoint(252,277);
			polygonMap.polygons[polyid].addPoint(214,283);
			polygonMap.polygons[polyid].addPoint(217,300);
			polygonMap.polygons[polyid].addPoint(235,319);
			polygonMap.polygons[polyid].addPoint(265,339);
			polygonMap.polygons[polyid].addPoint(275,352);
			polygonMap.polygons[polyid].addPoint(310,353);
			polygonMap.polygons[polyid].addPoint(309,312);
			polygonMap.polygons[polyid].addPoint(322,308);
			polygonMap.polygons[polyid].addPoint(304,279);
			polygonMap.polygons[polyid].addPoint(307,249);
			polygonMap.polygons[polyid].addPoint(419,248);
			polygonMap.polygons[polyid].addPoint(431,262);
			polygonMap.polygons[polyid].addPoint(389,274);
			polygonMap.polygons[polyid].addPoint(378,295);
			polygonMap.polygons[polyid].addPoint(408,311);
			polygonMap.polygons[polyid].addPoint(397,316);
			polygonMap.polygons[polyid].addPoint(378,309);
			polygonMap.polygons[polyid].addPoint(365,323);
			polygonMap.polygons[polyid].addPoint(342,360);
			polygonMap.polygons[polyid].addPoint(358,379);
			polygonMap.polygons[polyid].addPoint(205,379);
			polygonMap.polygons[polyid].addPoint(206,341);
			polygonMap.polygons[polyid].addPoint(212,325);
			polygonMap.polygons[polyid].addPoint(198,316);
			polygonMap.polygons[polyid].addPoint(162,298);
			polygonMap.polygons[polyid].addPoint(119,305);
			polygonMap.polygons[polyid].addPoint(99,338);
			polygonMap.polygons[polyid].addPoint(91,362);
			polygonMap.polygons[polyid].addPoint(79,372);
			polygonMap.polygons[polyid].addPoint(90,380);
			polygonMap.polygons[polyid].addPoint(4, 379);
		}
		else {
			polygonMap.polygons[polyid].addPoint(4,249);
			polygonMap.polygons[polyid].addPoint(418,251);
			polygonMap.polygons[polyid].addPoint(501,340);
			polygonMap.polygons[polyid].addPoint(507,379);
			polygonMap.polygons[polyid].addPoint(3,378);
			polyid++;
			polygonMap.polygons[polyid] = new Polygon();
			polygonMap.polygons[polyid].addPoint(243,269);
			polygonMap.polygons[polyid].addPoint(297,273);
			polygonMap.polygons[polyid].addPoint(318,306);
			polygonMap.polygons[polyid].addPoint(314,333);
			polygonMap.polygons[polyid].addPoint(266,348);
			polygonMap.polygons[polyid].addPoint(196,341);
			polygonMap.polygons[polyid].addPoint(174,303);
			polygonMap.polygons[polyid].addPoint(196,277);
		}
		//Create a graph based on the polygonMap
		polygonMap.createGraph();
	}
}
