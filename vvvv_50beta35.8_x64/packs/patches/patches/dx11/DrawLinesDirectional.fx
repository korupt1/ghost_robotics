//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 

float4x4 tV : VIEW;
float4x4 tVP : VIEWPROJECTION;
float4x4 tVI : VIEWINVERSE;
float4x4 tP: PROJECTION;
float4x4 tWIT: WORLDINVERSETRANSPOSE;
float4x4 tWV: WORLDVIEW;
Texture2D texture2d;



float3 lDir <string uiname="Light Direction";> = {0, -5, 2}; 
float4 lAmb  <bool color=true; String uiname="Ambient Color";>  = {0.15, 0.15, 0.15, 1};
float4 lDiff <bool color=true;String uiname="Diffuse Color";>  = {0.85, 0.85, 0.85, 1};
float4 lSpec <bool color=true; String uiname="Specular Color";> = {0.35, 0.35, 0.35, 1};
float lPower <String uiname="Power"; float uimin=3.0;> = 25.0; 

float4 c <bool color=true;> = 1;
float velColMult = 1;
float alpha;
float pCount;
float connectorCount;
#include "particle_constraints_struct.fxh"
StructuredBuffer<particle> pData;

float radius = 0.05f;
 
    float3 g_positions[4]:IMMUTABLE =
    {
        float3( -1, 1, 0 ),
        float3( 1, 1, 0 ),
        float3( -1, -1, 0 ),
        float3( 1, -1, 0 ),
    };
    float2 g_texcoords[4]:IMMUTABLE = 
    { 
        float2(0,1), 
        float2(1,1),
        float2(0,0),
        float2(1,0),
    };



SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

struct VS_IN
{
	uint iv : SV_VertexID;
	//float4 NormO : NORMAL;
};

struct vs2ps
{
    float4 PosWVP: SV_POSITION ;	
	float2 TexCd : TEXCOORD0 ;
	
	uint iv2 : PrimitiveID;
	float4 Diffuse: COLOR0;
    float4 Specular: COLOR1;
};

vs2ps VS(VS_IN input)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
	
	float3 p = pData[input.iv].pos;
	float3 v = pData[input.iv].vel;
	
    Out.PosWVP = float4(p,1);// mul(float4(po.xyz,1),tVP);
	
	//Out.Vcol = float4(saturate(v * velColMult)+0.5,1);
	
	Out.iv2 = input.iv;
	
	
	
	
	
	
	
    return Out;
}

[maxvertexcount(2)]
void GS(line vs2ps input[2], inout LineStream<vs2ps> SpriteStream)
{
    vs2ps output;
    
    //
    // Emit two new triangles
    //
    for(int i=0; i<2; i++)
    {
        float3 position = g_positions[i]*radius;
       // position = mul( position, (float3x3)tVI ) + input[i].PosWVP.xyz;
    	position = input[i].PosWVP.xyz;
    	float3 norm = mul(float3(0,0,-1),(float3x3)tVI );
        output.PosWVP = mul( float4(position,1.0), tVP );
        
        output.TexCd = g_texcoords[i];	
        //output.Vcol = input[i].Vcol;
    	
    	 float3 LightDirV = normalize(-mul(float4(lDir,0.0f), tV).xyz);
    	float3 NormV = normalize(mul(mul(norm, (float3x3)tWIT),(float3x3)tV).xyz);
    	   //view direction = inverse vertexposition in viewspace
    float4 PosV = mul(position, tWV);
    float3 ViewDirV = normalize(-PosV.xyz);

    //halfvector
    float3 H = normalize(ViewDirV + LightDirV);

    //compute blinn lighting
    float3 shades = lit(dot(NormV, LightDirV), dot(NormV, H), lPower).xyz;

    float4 diff = lDiff * shades.y;
    diff.a = 1;
    float4 spec = lSpec * shades.z;
    spec.a = 1;
      output.Diffuse = diff + lAmb;
    output.Specular = spec;	
    	
    	output.iv2 = input[i].iv2;
        SpriteStream.Append(output);
    }
    SpriteStream.RestartStrip();
}



float4 PS_Tex(vs2ps In): SV_Target
{
  //  float4 col = texture2d.Sample( g_samLinear, In.TexCd)*c;
	//if (col.r < 0.5f) { discard; }
	
	float4 col = texture2d.Sample(g_samLinear, In.TexCd.xy);
	uint division = pCount / connectorCount;
	
	if((In.iv2+1) % division == 0)
		discard;
	 else 
		 col.rgb *= In.Diffuse.xyz + In.Specular.xyz;

	col.a= alpha;
    return col;
}

technique10 Constant
{
	pass P0
	{
		
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetGeometryShader( CompileShader( gs_4_0, GS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Tex() ) );
	}
}




