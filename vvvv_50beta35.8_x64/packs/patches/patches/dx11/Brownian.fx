//define particle properties
#include "particle_struct.fxh"

float brwIndexShift;
float brwnStrenght;
int pCount;


StructuredBuffer<float3> rndDir;
// buffer which holds particle objects
RWStructuredBuffer<particle> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(128, 1, 1)]
void CSConstantForce( uint3 index : SV_DispatchThreadID )
{
	
		uint rndIndex = index.x + brwIndexShift;
		rndIndex = rndIndex % pCount;
		float3 brwnForce = rndDir[rndIndex];
		float3  acc = (brwnForce * brwnStrenght);
	
	Output[index.x].acc += acc;

}

technique10 Emitter
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}




