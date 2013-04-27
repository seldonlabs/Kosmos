frag = """precision mediump float;

varying vec3 vPos;
varying vec3 vTangent;
varying vec3 vBinormal;

float heightFunc(vec3 coord)
{
        vec3 v;

        float a = 0.0;
        //float p = 4.0;
        float p = 8.0;

        //for (int i = 0; i < 5; ++i) {
        for (int i = 0; i < 7; ++i) {
                v.x = coord.x * p; v.y = coord.y * p; v.z = coord.z * p;

                float ridged;

                ridged = 1.0 - abs(snoise(v));
                ridged /= float(i)+1.0;

                v.x = coord.x * p / 2.5; v.y = coord.y * p / 2.5; v.z = coord.z * p / 2.5;
                float k = (snoise(v)+1.0) / 2.0;

                v.x = coord.x * p / 1.0; v.y = coord.y * p / 1.0; v.z = coord.z * p / 1.0;

                a += ridged * k;
                
                if (i >= 3) {
                        v.x = coord.x * p * 8.0; v.y = coord.y * p * 8.0; v.z = coord.z * p * 8.0;
                        float rolling = (snoise(v)+1.0) / 2.0;
                        a += (rolling) * (1.0-k) / float(50);
                }

                p *= 2.0;
        }

        a /= 1.6;

        return a;
}

#define ONE_TEXEL (1.0/1024.0)


vec4 positionAndHeight(vec3 cubePos)
{
        vec3 pos = normalize(cubePos);
        float h = heightFunc(pos);
        pos *= 0.99 + h * 0.01;
        return vec4(pos, h);
}


void main(void) {
	vec4 h00 = positionAndHeight(vPos);
        vec4 h10 = positionAndHeight(vPos + ONE_TEXEL * vBinormal);
        vec4 h01 = positionAndHeight(vPos + ONE_TEXEL * vTangent);
        
        vec3 right = (h10.xyz - h00.xyz);
        vec3 forward = (h01.xyz - h00.xyz);
        vec3 normal = normalize(cross(right, forward));

        float height = h00.a;
        gl_FragColor = vec4((normal + 1.0) * 0.5, height);
 
        //gl_FragColor = vec4(vPos * 0.5 + 0.5, 1.0);
        //gl_FragColor = vec4(vPos.xy, 0.0, 1.0);
}

"""


vert = """
attribute vec2 aUV;
attribute vec3 aPos;
attribute vec3 aTangent;
attribute vec3 aBinormal;
varying vec3 vPos;
varying vec3 vTangent;
varying vec3 vBinormal;

uniform vec2 verticalViewport;

void main(void) {
	vPos = aPos;
        vTangent = aTangent;
        vBinormal = aBinormal;

        vec2 pos = aUV;
        pos.y = (pos.y - verticalViewport.x) / verticalViewport.y;
        pos = pos * 2.0 - 1.0;

	gl_Position = vec4(pos, 0.0, 1.0);
}

"""

xgl.addProgram("nearMapGenerator", vert, xgl.commonNoiseShaderSource + frag)
