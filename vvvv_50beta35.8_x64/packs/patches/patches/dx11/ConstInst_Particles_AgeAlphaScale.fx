//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tVI : VIEWINVERSE;
Texture2D texture2d; 
float Scale;
float MaxAge;
float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };

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
	float age:  TEXCOORD1;
	
};

float alpha;

vs2ps VS(VS_IN input)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
	//Load Particle Object Position
	float4 particlePos = float4(particles[input.ii].pos,1);
	//Scale Objects
	float4 Objects = (input.PosO * Scale);	
	//Scale Object in Respect to Age
	Objects *= saturate(particles[input.ii].age * 0.014);
	//InversTransformation with View for Billborad
	Objects = mul(Objects, tVI);
	//Translate Objects
	Objects += particlePos;
	Out.PosWVP  = mul(Objects,tWVP);
    Out.TexCd = input.TexCd;
	// Pass Age to PixelShader
	Out.age = particles[input.ii].age;
    return Out;
}




float4 PS_Tex(vs2ps In): SV_Target
{
	// Get Texture Color
    float4 col = texture2d.Sample( g_samLinear, In.TexCd) * cAmb;
	//Age to Alpha
	col.a = saturate((((In.age - MaxAge) * (-1)) / MaxAge) * (In.age / 20)) * alpha;
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




