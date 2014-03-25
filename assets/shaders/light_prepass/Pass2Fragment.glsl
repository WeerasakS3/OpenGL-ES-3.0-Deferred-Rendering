precision highp float;
uniform sampler2D s_GBuffer;
uniform sampler2D s_Depth;

uniform mat4    u_InvProj;

uniform vec2    u_Viewport;

uniform vec3    u_LightColor;
uniform vec3    u_LightPosition;
uniform float   u_LightSize;

varying vec4    v_Position;

vec3 decode(vec2 encoded)
{
    vec2 fenc = encoded*4.0 - 2.0;
    float f = dot(fenc,fenc);
    float g = sqrt(1.0 - f/4.0);
    vec3 normal;
    normal.xy = fenc*g;
    normal.z = 1.0 - f/2.0;
    return normal;
}

void main(void)
{
    /** Load texture values
     */
    vec2 tex_coord = gl_FragCoord.xy/u_Viewport;

    vec4 gbuffer_val = texture2D(s_GBuffer, tex_coord);
    vec3 normal = decode(gbuffer_val.rg);
    float specular_power = gbuffer_val.a;
    float depth = texture2D(s_Depth, tex_coord).r;

    /* Calculate the pixel's position in view space */
    vec4 view_pos = vec4(tex_coord*2.0-1.0, depth * 2.0 - 1.0, 1.0);
    view_pos = u_InvProj * view_pos;
    view_pos /= view_pos.w;

    vec3 light_dir = u_LightPosition - view_pos.xyz;
    float dist = length(light_dir);
    float size = u_LightSize;
    float attenuation = 1.0 - pow( clamp(dist/size, 0.0, 1.0), 2.0);
    light_dir = normalize(light_dir);

    /* Calculate diffuse lighting */
    float n_dot_l = clamp(dot(light_dir, normal), 0.0, 1.0);
    vec3 diffuse = u_LightColor * n_dot_l;

    vec3 final_color = attenuation * (diffuse);

    gl_FragColor = vec4(final_color, 1.0);
}
