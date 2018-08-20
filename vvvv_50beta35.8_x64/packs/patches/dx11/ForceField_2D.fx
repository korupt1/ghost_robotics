//@author: raul, milo
//@tags: ForceField 2D
//@credits: vux, dottore

Texture2D tex <string uiname="ForceField_2D";>;
float4x4 tFF_Inv <string uiname="Transform_ForceField_Inv";>;

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

#include "particle_struct.fxh"

RWStructuredBuffer<particle> Output : BACKBUFFER;

float fieldPower = 1;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(128, 1, 1)]
void CSConstantForce( uint3 DTid : SV_DispatchThreadID )
{
		//Read World Pos
		float3 pos_world = Output[DTid.x].pos;
		//Invers Transformation of ForceField Transform
		float3 pos_world_tff_Inv = mul(float4(pos_world,1),tFF_Inv).xyz;
	
//		if ((abs(pos_world_tff_Inv.x) < 0.5) && (abs(pos_world_tff_Inv.y) < 0.5) )
		if ((abs(pos_world_tff_Inv.x) <= 0.5) && (abs(pos_world_tff_Inv.y) <= 0.5) && (abs(pos_world_tff_Inv.z) <= 0.5))
	{	//Check if Particle is in ForceField Area
			//Convert Pos to TexCords
 			float2 pos_tex = ((pos_world_tff_Inv.xy * float2(1,-1)) + 0.5);
			//Load Force from ForceField2D
			float4 FieldForce = tex.SampleLevel(g_samLinear,(pos_tex),0) * fieldPower*0.1;
			Output[DTid.x].acc.xy += FieldForce.xy;
			
		}
	
}

technique10 Constant
{
	pass P0s
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}




