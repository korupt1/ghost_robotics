//define particle properties
#include "particle_struct.fxh"

float BounceFactor = 1;
int BoxCount;
// buffer which holds particle objects
RWStructuredBuffer<particle> Output : BACKBUFFER;
StructuredBuffer<float4x4> BoxTransform_Inverse;
StructuredBuffer<float4x4> BoxTransform;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(128, 1, 1)]
void CSConstantForce( uint3 index : SV_DispatchThreadID )
{
	for (int i = 0; i < BoxCount; i++) 
	{
		//Upper Plain Variable
		float3 Box = float3(0,0.5,0);
		//Read World Pos Particle
		float3 pos_world = Output[index.x].pos;
		//Invers Transformation of Box Transform
		float3 pos_world_tff_Inv = mul(float4(pos_world,1),BoxTransform_Inverse[i]).xyz;
		//Check if Particle is in Box
		if ((abs(pos_world_tff_Inv.x) < 0.5) && (abs(pos_world_tff_Inv.y) < 0.5) && (abs(pos_world_tff_Inv.z) < 0.5))
			{
				//Calc UppperPlain Y Valu in World
				Box = mul(float4(Box,1),BoxTransform[i]).xyz;
				//Set YPos Particle to YPos UpperPlain of Box
				Output[index.x].pos.y = Box.y;
				//Invert Y Velocity
				Output[index.x].vel.y *= -1 * BounceFactor;
				//Set Y Acceleration to 
				Output[index.x].acc = 0;
			}
	}
		  
}

technique10 BoxBehavior_Bounce
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}




