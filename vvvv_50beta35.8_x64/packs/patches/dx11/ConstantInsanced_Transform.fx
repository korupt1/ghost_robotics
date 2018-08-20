//@author: raul, milo
//@help: constant shader, Instance, VS Rotate
//@credits: vux

Texture2D texture2d; 
Texture2D ForceField_Texture; 

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = Clamp;
    AddressV = Clamp;
};

StructuredBuffer< float4x4> sbWorld;
StructuredBuffer<float4> sbColor;
StructuredBuffer<float2> ForceField_Pos;

cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;
	float4x4 tW : WORLD;
	int colorcount = 1;
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
	float4 Color: TEXCOORD0;
    float2 TexCd: TEXCOORD1;
	
};
//CartesiaToSpherical Coordinates/////////////////////////////////////////
float2 CartesianToSpherical(float3 cartesian)
{
  float2 spherical;

  spherical.x = atan2(cartesian.y, cartesian.x) / 3.14159f;
  spherical.y = cartesian.z;

  return spherical * 0.5f + 0.5f;
}
//Rotation Matrix/////////////////////////////////////////////////////////
float TwoPi = 6.28318530717959;
float4x4 Vrotate(float rotX,float rotY, float rotZ)
  {
   rotX *= TwoPi;
   rotY *= TwoPi;
   rotZ *= TwoPi;
   float sx = sin(rotX);
   float cx = cos(rotX);
   float sy = sin(rotY);
   float cy = cos(rotY);
   float sz = sin(rotZ);
   float cz = cos(rotZ);
 
   return float4x4( cz*cy+sz*sx*sy, sz*cx, cz*-sy+sz*sx*cy, 0,
                   -sz*cy+cz*sx*sy, cz*cx, sz*sy+cz*sx*cy , 0,
                    cx * sy       ,-sx   , cx * cy        , 0,
                    0             , 0    , 0              , 1);
  }
//////////////////////////////////////////////////////////////////////////

vs2ps VS(VS_IN input)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
	//Load Transforms	
	float4x4 w = sbWorld[input.ii];
	//Load ForceField Position
	float2 FF_Pos = ForceField_Pos[input.ii];
	//Load Force of ForcField2D
	float4 Force = ForceField_Texture.SampleLevel(g_samLinear, FF_Pos.xy, 0);

	//Rotate Objects in Force Direction
	float2 Test = CartesianToSpherical(Force.xyz);
	float4 Pos_ForceRot = mul(input.PosO,Vrotate(Test.y,Test.y,Test.x*(1)));
//	float4 Pos_ForceRot = mul(input.PosO,Vrotate(0,0,0));
	w = mul(w,tW);
	//VP Transform of Objects
    Out.PosWVP  = mul(Pos_ForceRot,mul(w,tVP));
//	Out.PosWVP  = mul(w,tVP);
	//Load Color
	Out.Color = sbColor[input.ii % colorcount];
	//Load & Pass TexCD
    Out.TexCd = input.TexCd;
    return Out;
}

float4 PS_Tex(vs2ps In): SV_Target
{
    float4 col = texture2d.Sample( g_samLinear, In.TexCd) * In.Color;
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




