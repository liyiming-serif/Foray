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
// Use for radial progress bars with a backfill color.
// Fill progress with sprite. Otherwise
// draw the sprite in a back color.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3 bgColor;
uniform vec2 angles; //(min,max), radians, [-PI,PI)
uniform vec2 origin;
uniform vec4 spriteUVs; //left, top, 1/width, 1/height
                        //used to get true uv-coords.
                        
// Draw from angles[0] -> angles[1] going anti-clockwise
// Edge case: angles[0] == angles[1] will draw *nothing*
bool pixelWithinAngle(vec2 pos)
{
    if(angles[0] == angles[1]){
        return false;
    }
    
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
    vec4 baseColor = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
    vec2 pos = (v_vTexcoord-spriteUVs.xy)*spriteUVs.zw;
    if(pixelWithinAngle(pos))
    {
        gl_FragColor = baseColor;
    }
    else
    {
        gl_FragColor = vec4(bgColor, baseColor.a);
    }
}

