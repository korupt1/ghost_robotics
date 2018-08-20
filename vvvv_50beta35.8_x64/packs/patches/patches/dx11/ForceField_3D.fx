//@author: raul, milo
//@tags: ForceField 2D
//@credits: vux, dottore

Texture3D tex <string uiname="ForceField_3D";>;
float4x4 tFF_Inv <string uiname="Transform_ForceField_Inv";>;

#include "particle_struct.fxh"
RWStructuredBuffer<particle> Output : BACKBUFFER;

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

SamplerState volumeSampler // : IMMUTABLE
{
	Filter =MIN_MAG_MIP_LINEAR;
	AddressU = Wrap;
	AddressV = Wrap;
	Addressw = Wrap;
};



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
	
		if ((abs(pos_world_tff_Inv.x) <= 0.5) && (abs(pos_world_tff_Inv.y) <= 0.5) && (abs(pos_world_tff_Inv.z) <= 0.5))
		{	//Check if Particle is in ForceField Area
			//Convert Pos to TexCords
 			float3 pos_tex = ((pos_world_tff_Inv * float3(1,-1,1)) + 0.5);
			//Load Force from ForceField3D
			float4 FieldForce = tex.SampleLevel(volumeSampler,(pos_tex),0) * fieldPower*.01;
			//Add Force to Acceleration and Add Mass??? Is this Correct?
			Output[DTid.x].acc += FieldForce.xyz;// * Output[DTid.x].mrl.x;
		}
}

technique10 Constant
{
	pass P0s
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}




