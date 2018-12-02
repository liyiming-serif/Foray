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
// Highlight all pixels within a certain angle red/green;
// apply palette swap shader otherwise.
// Hit this spot to force enemy pilot to abandon plane.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D palette;
uniform float row;
uniform int onTarget; // is hitting weak spot?
uniform vec2 angles; //(min,max), radians, anti-clockwise, [0,2*PI]
uniform vec4 sprite_uvs;//left, top, 1/width, 1/height
                        //used to get true uv-coords.

const float PI = 3.14159265359; //because gm's glsles is ancient.

bool in_range(vec2 pos)
{
    pos.x-=0.5;
    pos.y-=0.5;
    if(pos.y==0.0 && pos.x==0.0){
        return true;
    }
    float angle = atan(pos.y,pos.x);
    if (angle < 0.0){
        angle += 2.0*PI;
    }
    
    if(angles[0]>angles[1]){
        return (angle >= angles[0]) || (angle < angles[1]);
    }
    return (angle >= angles[0]) && (angle < angles[1]);
}

void main()
{
    vec4 base_color = texture2D( gm_BaseTexture, v_vTexcoord );
    vec2 pos = (v_vTexcoord-sprite_uvs.xy)*sprite_uvs.zw;
    if(in_range(pos)){
        if(onTarget==1){ //flash green
            gl_FragColor = vec4(0.328125,0.89453125,0.0,base_color.a);
        }
        else { //flash red
            gl_FragColor = vec4(0.85546875,0.09375,0.26953125,base_color.a);
        }
    }
    else{
        gl_FragColor = texture2D(palette, vec2( base_color.r, row ));
    }
}
