//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.	
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~//
// Highlight all pixels within a certain angle red/blue;
// apply palette swap shader otherwise.
// Hit this spot to force enemy pilot to abandon plane.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D palette;
uniform float row;
uniform float onTarget; // is hitting weak spot? USING GML BOOL SEMANTICS!!!
uniform vec2 angles; //(min,max), radians, anti-clockwise, [-PI,PI]
uniform vec2 origin;
uniform vec4 spriteUVs; //left, top, 1/width, 1/height
                        //used to get true uv-coords.
                        
uniform float isMeter; //(cursor only) hide instead of flash

const float PI = 3.14159265359; //because gm's glsles is ancient.

bool inRange(vec2 pos)
{
    pos.x-=origin.x;
    pos.y-=origin.y;
    if(pos.y==0.0 && pos.x==0.0){
        return true;
    }
    float angle = atan(pos.y,pos.x);
    
    if(angles[0]>angles[1]){
        return (angle >= angles[0]) || (angle < angles[1]);
    }
    return (angle >= angles[0]) && (angle < angles[1]);
}

void main()
{
    vec4 baseColor = texture2D( gm_BaseTexture, v_vTexcoord );
    vec2 pos = (v_vTexcoord-spriteUVs.xy)*spriteUVs.zw;
    if(inRange(pos)){
        if(isMeter>=0.5){ //hide a slice of the sprite
            gl_FragColor = vec4(0.0,0.0,0.0,0.0);
        }
        else if(onTarget>=0.5){ //flash blue
            gl_FragColor = vec4(0.30078125,0.93359375,0.69140625,baseColor.a);
            //gl_FragColor = texture2D(palette, vec2( baseColor.r, 0.9921875));
        }
        else { //flash red
            gl_FragColor = vec4(0.85546875,0.09375,0.26953125,baseColor.a);
            //gl_FragColor = texture2D(palette, vec2( baseColor.r, 0.99609375));
        }
    }
    else{ //normal pal swap
        gl_FragColor = texture2D(palette, vec2( baseColor.r, row ));
    }
}

