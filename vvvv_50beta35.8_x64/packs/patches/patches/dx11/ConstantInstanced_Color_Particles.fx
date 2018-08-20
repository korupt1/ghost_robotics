//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tVI : VIEWINVERSE;
Texture2D texture2d; 
float Scale;
float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;

#include "particle_struct.fxh"
StructuredBuffer<particle> particles;


SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;
	float4x4 tW : WORLD;
};

struct VS_IN
{
	uint ii : SV_InstanceID;
	float4 PosO : POSITION;
	float2 TexCd : TEXCOORD0;
};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;	
    float2 TexCd: TEXCOORD0;
	float4 color_Tex : TEXCOORD1;
};

float alpha;

vs2ps VS(VS_IN input)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
	//Load Particle Object
	float4 particlePos = float4(particles[input.ii].pos,1);
	//Scale Objects
	float4 Objects = (input.PosO * Scale);
	//InversTransformation with View for Billborad
	Objects = mul(Objects, tVI);
	//Translate Objects
	Objects += particlePos;


	Out.PosWVP  = mul(Objects,tWVP);
	Out.color_Tex = particles[input.ii].col;
    Out.TexCd = mul(float4(input.TexCd,1,1), tTex).xy;
    return Out;
}




float4 PS_Tex(vs2ps In): SV_Target
{
//    float4 col = texture2d.Sample( g_samLinear, In.TexCd) * alpha;
	float4 col = In.color_Tex;
//	col.a = alpha;
    return col;
}





technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Tex() ) );
	}
}




