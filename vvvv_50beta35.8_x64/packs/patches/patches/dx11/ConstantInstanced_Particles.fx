#include "particle_struct.fxh"
StructuredBuffer<particle> particles;

float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tVI : VIEWINVERSE;
Texture2D texture2d; 
float Scale;
float alpha;
bool useVelocityColor = false;
float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;

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
	float4 VelCol : COLOR ;
};

vs2ps VS(VS_IN input)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
	//Load Particle Object
	float3 pPos = particles[input.ii].pos;
	float3 vel = particles[input.ii].vel;
	//Scale Objects
	float4 pos = float4(input.PosO.xyz * Scale * particles[input.ii].mass ,0);
	//InversTransformation with View for Billborad
	pos = mul(pos, tVI);
	//Translate Objects
	pos += float4(pPos,1);
	//Translate Object
	Out.PosWVP  = mul(pos,tWVP);
	//Out.VelCol = (float4(abs(vel) +.3,1);
	Out.VelCol = float4(normalize(vel),1);
    Out.TexCd = mul(float4(input.TexCd,1,1), tTex).xy;
    return Out;
}

float4 PS_Tex(vs2ps In): SV_Target
{
    float4 col = texture2d.Sample( g_samLinear, In.TexCd) * alpha;
	if (useVelocityColor)
		col = In.VelCol;
	col.a = alpha;
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