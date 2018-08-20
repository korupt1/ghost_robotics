
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tVI : VIEWINVERSE;
Texture2D texture2d; 

float Scale;
float MaxAge;
float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;

struct particle
{
	float3 pos;
	float3 acc;
	float3 vel;		
	int age;	
};

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
	float Age : TEXCOORD1;
};

float alpha;

vs2ps VS(VS_IN input)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
	//Load Particle Object
	float4 particlePos = float4(particles[input.ii].pos,1);
	float3 vel = particles[input.ii].vel;
	//Scale Objects
	float4 Objects = mul(input.PosO,Scale * (0.1));
	//InversTransformation with View for Billborad
	Objects = mul(Objects, tVI);
	//Translate Objects
	Objects += particlePos;
	//Translate Object

	Out.PosWVP  = mul(Objects,tWVP);
//	Out.VelCol = float4(saturate(vel * 1)+.5,1);
	Out.Age = particles[input.ii].age;
	//Out.VelCol = float4(saturate(vel *.01)+.5,1);
//	Out.TexCd = input.TexCd;
    Out.TexCd = mul(float4(input.TexCd,1,1), tTex).xy;
    return Out;
}




float4 PS_Tex(vs2ps In): SV_Target
{
    float4 col = texture2d.Sample( g_samLinear, In.TexCd) * alpha;
	float a = In.Age / MaxAge;
	col.a *= (a-1) * (-1);
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




