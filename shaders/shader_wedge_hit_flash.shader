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
// Apply wedge flash atop hit flash.
//
// Use this when plane is stealable while it's taking hits. Combining
// two shaders instead of applying both sacrifices code readability for
// performance boost.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float onTarget; // is hitting weak spot? USING GML BOOL SEMANTICS!!!
uniform vec2 angles; //(min,max), radians, anti-clockwise, [-PI,PI]
uniform vec2 origin;
uniform vec4 spriteUVs;//left, top, 1/width, 1/height
                        //used to get true uv-coords.

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
        if(onTarget>=0.5){ //flash green
            gl_FragColor = vec4(0.328125,0.89453125,0.0,baseColor.a);
        }
        else { //flash red
            gl_FragColor = vec4(0.85546875,0.09375,0.26953125,baseColor.a);
        }
    }
    else{ //normal hit flash
        gl_FragColor = vec4(1.0,1.0,0.7265625,baseColor.a);
    }
}

